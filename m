Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9B96B02FD
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p17so3421276wmd.5
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:45 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f185si1962699wmg.188.2017.07.24.16.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:44 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 05/23] percpu: unify allocation of schunk and dchunk
Date: Mon, 24 Jul 2017 19:02:02 -0400
Message-ID: <20170724230220.21774-6-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Create a common allocator for first chunk initialization,
pcpu_alloc_first_chunk. Comments for this function will be added in a
later patch once the bitmap allocator is added.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 73 +++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 40 insertions(+), 33 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 851aa81..2e785a7 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -708,6 +708,36 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme,
 	pcpu_chunk_relocate(chunk, oslot);
 }
 
+static struct pcpu_chunk * __init pcpu_alloc_first_chunk(void *base_addr,
+							 int start_offset,
+							 int map_size,
+							 int *map,
+							 int init_map_size)
+{
+	struct pcpu_chunk *chunk;
+
+	chunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
+	INIT_LIST_HEAD(&chunk->list);
+	INIT_LIST_HEAD(&chunk->map_extend_list);
+	chunk->base_addr = base_addr;
+	chunk->start_offset = start_offset;
+	chunk->map = map;
+	chunk->map_alloc = init_map_size;
+
+	/* manage populated page bitmap */
+	chunk->immutable = true;
+	bitmap_fill(chunk->populated, pcpu_unit_pages);
+	chunk->nr_populated = pcpu_unit_pages;
+
+	chunk->contig_hint = chunk->free_size = map_size;
+	chunk->map[0] = 1;
+	chunk->map[1] = chunk->start_offset;
+	chunk->map[2] = (chunk->start_offset + chunk->free_size) | 1;
+	chunk->map_used = 2;
+
+	return chunk;
+}
+
 static struct pcpu_chunk *pcpu_alloc_chunk(void)
 {
 	struct pcpu_chunk *chunk;
@@ -1570,6 +1600,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	unsigned int cpu;
 	int *unit_map;
 	int group, unit, i;
+	int map_size, start_offset;
 
 #define PCPU_SETUP_BUG_ON(cond)	do {					\
 	if (unlikely(cond)) {						\
@@ -1678,44 +1709,20 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 * covers static area + reserved area (mostly used for module
 	 * static percpu allocation).
 	 */
-	schunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
-	INIT_LIST_HEAD(&schunk->list);
-	INIT_LIST_HEAD(&schunk->map_extend_list);
-	schunk->base_addr = base_addr;
-	schunk->start_offset = ai->static_size;
-	schunk->map = smap;
-	schunk->map_alloc = ARRAY_SIZE(smap);
-	schunk->immutable = true;
-	bitmap_fill(schunk->populated, pcpu_unit_pages);
-	schunk->nr_populated = pcpu_unit_pages;
-
-	schunk->free_size = ai->reserved_size ?: ai->dyn_size;
-	schunk->contig_hint = schunk->free_size;
-	schunk->map[0] = 1;
-	schunk->map[1] = schunk->start_offset;
-	schunk->map[2] = (ai->static_size + schunk->free_size) | 1;
-	schunk->map_used = 2;
+	start_offset = ai->static_size;
+	map_size = ai->reserved_size ?: ai->dyn_size;
+	schunk = pcpu_alloc_first_chunk(base_addr, start_offset, map_size,
+					smap, ARRAY_SIZE(smap));
 
 	/* init dynamic chunk if necessary */
 	if (ai->reserved_size) {
 		pcpu_reserved_chunk = schunk;
 
-		dchunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
-		INIT_LIST_HEAD(&dchunk->list);
-		INIT_LIST_HEAD(&dchunk->map_extend_list);
-		dchunk->base_addr = base_addr;
-		dchunk->start_offset = ai->static_size + ai->reserved_size;
-		dchunk->map = dmap;
-		dchunk->map_alloc = ARRAY_SIZE(dmap);
-		dchunk->immutable = true;
-		bitmap_fill(dchunk->populated, pcpu_unit_pages);
-		dchunk->nr_populated = pcpu_unit_pages;
-
-		dchunk->contig_hint = dchunk->free_size = ai->dyn_size;
-		dchunk->map[0] = 1;
-		dchunk->map[1] = dchunk->start_offset;
-		dchunk->map[2] = (dchunk->start_offset + dchunk->free_size) | 1;
-		dchunk->map_used = 2;
+		start_offset = ai->static_size + ai->reserved_size;
+		map_size = ai->dyn_size;
+		dchunk = pcpu_alloc_first_chunk(base_addr, start_offset,
+						map_size, dmap,
+						ARRAY_SIZE(dmap));
 	}
 
 	/* link the first chunk in */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
