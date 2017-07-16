Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 980FB6B059A
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:43 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a2so135374578pgn.15
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:43 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x7si10048737pge.177.2017.07.15.19.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:42 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 07/10] percpu: fix misnomer in schunk/dchunk variable names
Date: Sat, 15 Jul 2017 22:23:12 -0400
Message-ID: <20170716022315.19892-8-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

With moving the base_addr in the chunks responsible for serving the
first chunk up, the use of schunk/dchunk in pcpu_setup_first_chunk no
longer makes sense. This makes the linking in the first chunk code not
rely on a ternary and renames the variables to a shared variable, chunk,
because the allocation path is sequential.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 96 ++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 48 insertions(+), 48 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index c74ad68..9dd28a2 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1597,7 +1597,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	static int dmap[PERCPU_DYNAMIC_EARLY_SLOTS] __initdata;
 	size_t dyn_size = ai->dyn_size;
 	size_t size_sum = ai->static_size + ai->reserved_size + dyn_size;
-	struct pcpu_chunk *schunk, *dchunk = NULL;
+	struct pcpu_chunk *chunk;
 	unsigned long *group_offsets;
 	size_t *group_sizes;
 	unsigned long *unit_off;
@@ -1709,13 +1709,13 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		INIT_LIST_HEAD(&pcpu_slot[i]);
 
 	/*
-	 * Initialize static chunk.
-	 * The static region is dropped as those addresses are already
-	 * allocated and do not rely on chunk->base_addr.
-	 * reserved_size == 0:
-	 *      the static chunk covers the dynamic area
-	 * reserved_size > 0:
-	 *      the static chunk covers the reserved area
+	 * Initialize first chunk.
+	 * pcpu_first_chunk will always manage the dynamic region of the
+	 * first chunk.  The static region is dropped as those addresses
+	 * are already allocated and do not rely on chunk->base_addr.
+	 *
+	 * ai->reserved == 0:
+	 *	reserved_chunk == NULL;
 	 *
 	 * If the static area is not page aligned, the region adjacent
 	 * to the static area must have its base_addr be offset into
@@ -1730,61 +1730,61 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	map_size_bytes = (ai->reserved_size ?: ai->dyn_size) +
 			 pcpu_reserved_offset;
 
-	/* schunk allocation */
-	schunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
-	INIT_LIST_HEAD(&schunk->list);
-	INIT_LIST_HEAD(&schunk->map_extend_list);
-	schunk->base_addr = (void *)aligned_addr;
-	schunk->map = smap;
-	schunk->map_alloc = ARRAY_SIZE(smap);
-	schunk->immutable = true;
-	bitmap_fill(schunk->populated, pcpu_unit_pages);
-	schunk->nr_populated = pcpu_unit_pages;
+	/* chunk adjacent to static region allocation */
+	chunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
+	INIT_LIST_HEAD(&chunk->list);
+	INIT_LIST_HEAD(&chunk->map_extend_list);
+	chunk->base_addr = (void *)aligned_addr;
+	chunk->map = smap;
+	chunk->map_alloc = ARRAY_SIZE(smap);
+	chunk->immutable = true;
+	bitmap_fill(chunk->populated, pcpu_unit_pages);
+	chunk->nr_populated = pcpu_unit_pages;
 
-	schunk->nr_pages = map_size_bytes >> PAGE_SHIFT;
+	chunk->nr_pages = map_size_bytes >> PAGE_SHIFT;
 
 	if (ai->reserved_size) {
-		schunk->free_size = ai->reserved_size;
-		pcpu_reserved_chunk = schunk;
+		chunk->free_size = ai->reserved_size;
+		pcpu_reserved_chunk = chunk;
 	} else {
-		schunk->free_size = dyn_size;
+		chunk->free_size = dyn_size;
 		dyn_size = 0;			/* dynamic area covered */
 	}
-	schunk->contig_hint = schunk->free_size;
+	chunk->contig_hint = chunk->free_size;
 
 	if (pcpu_reserved_offset) {
-		schunk->has_reserved = true;
-		schunk->map[0] = 1;
-		schunk->map[1] = pcpu_reserved_offset;
-		schunk->map_used = 1;
+		chunk->has_reserved = true;
+		chunk->map[0] = 1;
+		chunk->map[1] = pcpu_reserved_offset;
+		chunk->map_used = 1;
 	}
-	if (schunk->free_size)
-		schunk->map[++schunk->map_used] = map_size_bytes;
-	schunk->map[schunk->map_used] |= 1;
+	if (chunk->free_size)
+		chunk->map[++chunk->map_used] = map_size_bytes;
+	chunk->map[chunk->map_used] |= 1;
 
-	/* init dynamic chunk if necessary */
+	/* init dynamic region of first chunk if necessary */
 	if (dyn_size) {
-		dchunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
-		INIT_LIST_HEAD(&dchunk->list);
-		INIT_LIST_HEAD(&dchunk->map_extend_list);
-		dchunk->base_addr = base_addr + ai->static_size +
+		chunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
+		INIT_LIST_HEAD(&chunk->list);
+		INIT_LIST_HEAD(&chunk->map_extend_list);
+		chunk->base_addr = base_addr + ai->static_size +
 				    ai->reserved_size;
-		dchunk->map = dmap;
-		dchunk->map_alloc = ARRAY_SIZE(dmap);
-		dchunk->immutable = true;
-		bitmap_fill(dchunk->populated, pcpu_unit_pages);
-		dchunk->nr_populated = pcpu_unit_pages;
-
-		dchunk->contig_hint = dchunk->free_size = dyn_size;
-		dchunk->map[0] = 0;
-		dchunk->map[1] = dchunk->free_size | 1;
-		dchunk->map_used = 1;
-
-		dchunk->nr_pages = dyn_size >> PAGE_SHIFT;
+		chunk->map = dmap;
+		chunk->map_alloc = ARRAY_SIZE(dmap);
+		chunk->immutable = true;
+		bitmap_fill(chunk->populated, pcpu_unit_pages);
+		chunk->nr_populated = pcpu_unit_pages;
+
+		chunk->contig_hint = chunk->free_size = dyn_size;
+		chunk->map[0] = 0;
+		chunk->map[1] = chunk->free_size | 1;
+		chunk->map_used = 1;
+
+		chunk->nr_pages = dyn_size >> PAGE_SHIFT;
 	}
 
 	/* link the first chunk in */
-	pcpu_first_chunk = dchunk ?: schunk;
+	pcpu_first_chunk = chunk;
 	pcpu_nr_empty_pop_pages +=
 		pcpu_count_occupied_pages(pcpu_first_chunk, 1);
 	pcpu_chunk_relocate(pcpu_first_chunk, -1);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
