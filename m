Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E99AF6B03BD
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z48so24248962wrc.4
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:56 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u62si6274342wmd.112.2017.07.24.16.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:55 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 16/23] percpu: add first_bit to keep track of the first free in the bitmap
Date: Mon, 24 Jul 2017 19:02:13 -0400
Message-ID: <20170724230220.21774-17-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

This patch adds first_bit to keep track of the first free bit in the
bitmap. This hint helps prevent scanning of fully allocated blocks.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-internal.h |  2 +-
 mm/percpu-stats.c    |  1 +
 mm/percpu.c          | 17 +++++++++++++++--
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index 252ae9e..e60e049 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -36,7 +36,7 @@ struct pcpu_chunk {
 	struct pcpu_block_md	*md_blocks;	/* metadata blocks */
 
 	void			*data;		/* chunk data */
-	int			first_free;	/* no free below this */
+	int			first_bit;	/* no free below this */
 	bool			immutable;	/* no [de]population allowed */
 	int			start_offset;	/* the overlap with the previous
 						   region to have a page aligned
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index ad03d73..6142484 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -121,6 +121,7 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 	P("nr_alloc", chunk->nr_alloc);
 	P("max_alloc_size", chunk->max_alloc_size);
 	P("empty_pop_pages", chunk->nr_empty_pop_pages);
+	P("first_bit", chunk->first_bit);
 	P("free_bytes", chunk->free_bytes);
 	P("contig_bytes", chunk->contig_bits * PCPU_MIN_ALLOC_SIZE);
 	P("sum_frag", sum_frag);
diff --git a/mm/percpu.c b/mm/percpu.c
index 6bddc02..ad70c67 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -420,7 +420,7 @@ static void pcpu_chunk_refresh_hint(struct pcpu_chunk *chunk)
 	chunk->contig_bits = 0;
 
 	bits = nr_empty_pop_pages = 0;
-	pcpu_for_each_unpop_region(chunk->alloc_map, rs, re, 0,
+	pcpu_for_each_unpop_region(chunk->alloc_map, rs, re, chunk->first_bit,
 				   pcpu_chunk_map_bits(chunk)) {
 		bits = re - rs;
 
@@ -639,7 +639,8 @@ static int pcpu_find_block_fit(struct pcpu_chunk *chunk, int alloc_bits,
 	int bit_off, bits;
 	int re; /* region end */
 
-	pcpu_for_each_unpop_region(chunk->alloc_map, bit_off, re, 0,
+	pcpu_for_each_unpop_region(chunk->alloc_map, bit_off, re,
+				   chunk->first_bit,
 				   pcpu_chunk_map_bits(chunk)) {
 		bits = re - bit_off;
 
@@ -708,6 +709,13 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
 
 	chunk->free_bytes -= alloc_bits * PCPU_MIN_ALLOC_SIZE;
 
+	/* update first free bit */
+	if (bit_off == chunk->first_bit)
+		chunk->first_bit = find_next_zero_bit(
+					chunk->alloc_map,
+					pcpu_chunk_map_bits(chunk),
+					bit_off + alloc_bits);
+
 	pcpu_block_update_hint_alloc(chunk, bit_off, alloc_bits);
 
 	pcpu_chunk_relocate(chunk, oslot);
@@ -743,6 +751,9 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int off)
 	/* update metadata */
 	chunk->free_bytes += bits * PCPU_MIN_ALLOC_SIZE;
 
+	/* update first free bit */
+	chunk->first_bit = min(chunk->first_bit, bit_off);
+
 	pcpu_block_update_hint_free(chunk, bit_off, bits);
 
 	pcpu_chunk_relocate(chunk, oslot);
@@ -834,6 +845,8 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 		set_bit(0, chunk->bound_map);
 		set_bit(offset_bits, chunk->bound_map);
 
+		chunk->first_bit = offset_bits;
+
 		pcpu_block_update_hint_alloc(chunk, 0, offset_bits);
 	}
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
