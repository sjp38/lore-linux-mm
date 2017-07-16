Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0A0E6B059B
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p1so129859966pfl.2
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:44 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i7si10186415plk.473.2017.07.15.19.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:43 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 08/10] percpu: change the number of pages marked in the first_chunk bitmaps
Date: Sat, 15 Jul 2017 22:23:13 -0400
Message-ID: <20170716022315.19892-9-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

This patch changes the allocator to only mark allocated pages for the
region the population bitmap is used for. Prior, the bitmap was marked
completely used as the first chunk was allocated and immutable. This is
misleading because the first chunk may not be completely filled.
Additionally, with moving the base_addr up in the previous patch, the
population map no longer corresponds to what is being checked.

pcpu_nr_empty_pop_pages is used to ensure there are a handful of free
pages around to serve atomic allocations. A new field, nr_empty_pop_pages,
is added to the pcpu_chunk struct to keep track of the number of empty
pages. This field is needed as the number of empty populated pages is
globally kept track of and deltas are used to update it. This new field
is exposed in percpu_stats.

Now that chunk->nr_pages is the number of pages the chunk is serving, it
is nice to use this in the work function for population and freeing of
chunks rather than use the global variable pcpu_unit_pages.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-internal.h |  1 +
 mm/percpu-stats.c    |  1 +
 mm/percpu.c          | 34 +++++++++++++++++++++-------------
 3 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index 56e1aba..f0776f6 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -30,6 +30,7 @@ struct pcpu_chunk {
 	int                     nr_pages;       /* # of PAGE_SIZE pages served
 						   by this chunk */
 	int			nr_populated;	/* # of populated pages */
+	int			nr_empty_pop_pages; /* # of empty populated pages */
 	unsigned long		populated[];	/* populated bitmap */
 };
 
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index 44e561d..6fc04b1 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -99,6 +99,7 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 
 	P("nr_alloc", chunk->nr_alloc);
 	P("max_alloc_size", chunk->max_alloc_size);
+	P("empty_pop_pages", chunk->nr_empty_pop_pages);
 	P("free_size", chunk->free_size);
 	P("contig_hint", chunk->contig_hint);
 	P("sum_frag", sum_frag);
diff --git a/mm/percpu.c b/mm/percpu.c
index 9dd28a2..fb01841 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1164,7 +1164,7 @@ static void pcpu_balance_workfn(struct work_struct *work)
 	list_for_each_entry_safe(chunk, next, &to_free, list) {
 		int rs, re;
 
-		pcpu_for_each_pop_region(chunk, rs, re, 0, pcpu_unit_pages) {
+		pcpu_for_each_pop_region(chunk, rs, re, 0, chunk->nr_pages) {
 			pcpu_depopulate_chunk(chunk, rs, re);
 			spin_lock_irq(&pcpu_lock);
 			pcpu_chunk_depopulated(chunk, rs, re);
@@ -1221,7 +1221,7 @@ static void pcpu_balance_workfn(struct work_struct *work)
 
 		spin_lock_irq(&pcpu_lock);
 		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
-			nr_unpop = pcpu_unit_pages - chunk->nr_populated;
+			nr_unpop = chunk->nr_pages - chunk->nr_populated;
 			if (nr_unpop)
 				break;
 		}
@@ -1231,7 +1231,7 @@ static void pcpu_balance_workfn(struct work_struct *work)
 			continue;
 
 		/* @chunk can't go away while pcpu_alloc_mutex is held */
-		pcpu_for_each_unpop_region(chunk, rs, re, 0, pcpu_unit_pages) {
+		pcpu_for_each_unpop_region(chunk, rs, re, 0, chunk->nr_pages) {
 			int nr = min(re - rs, nr_to_pop);
 
 			ret = pcpu_populate_chunk(chunk, rs, rs + nr);
@@ -1604,6 +1604,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	unsigned int cpu;
 	int *unit_map;
 	int group, unit, i;
+	int chunk_pages;
 	unsigned long tmp_addr, aligned_addr;
 	unsigned long map_size_bytes;
 
@@ -1729,19 +1730,21 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	map_size_bytes = (ai->reserved_size ?: ai->dyn_size) +
 			 pcpu_reserved_offset;
+	chunk_pages = map_size_bytes >> PAGE_SHIFT;
 
 	/* chunk adjacent to static region allocation */
-	chunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
+	chunk = memblock_virt_alloc(sizeof(struct pcpu_chunk) +
+				     BITS_TO_LONGS(chunk_pages), 0);
 	INIT_LIST_HEAD(&chunk->list);
 	INIT_LIST_HEAD(&chunk->map_extend_list);
 	chunk->base_addr = (void *)aligned_addr;
 	chunk->map = smap;
 	chunk->map_alloc = ARRAY_SIZE(smap);
 	chunk->immutable = true;
-	bitmap_fill(chunk->populated, pcpu_unit_pages);
-	chunk->nr_populated = pcpu_unit_pages;
+	bitmap_fill(chunk->populated, chunk_pages);
+	chunk->nr_populated = chunk->nr_empty_pop_pages = chunk_pages;
 
-	chunk->nr_pages = map_size_bytes >> PAGE_SHIFT;
+	chunk->nr_pages = chunk_pages;
 
 	if (ai->reserved_size) {
 		chunk->free_size = ai->reserved_size;
@@ -1754,6 +1757,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	if (pcpu_reserved_offset) {
 		chunk->has_reserved = true;
+		chunk->nr_empty_pop_pages--;
 		chunk->map[0] = 1;
 		chunk->map[1] = pcpu_reserved_offset;
 		chunk->map_used = 1;
@@ -1764,7 +1768,11 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	/* init dynamic region of first chunk if necessary */
 	if (dyn_size) {
-		chunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
+		chunk_pages = dyn_size >> PAGE_SHIFT;
+
+		/* chunk allocation */
+		chunk = memblock_virt_alloc(sizeof(struct pcpu_chunk) +
+					     BITS_TO_LONGS(chunk_pages), 0);
 		INIT_LIST_HEAD(&chunk->list);
 		INIT_LIST_HEAD(&chunk->map_extend_list);
 		chunk->base_addr = base_addr + ai->static_size +
@@ -1772,21 +1780,21 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		chunk->map = dmap;
 		chunk->map_alloc = ARRAY_SIZE(dmap);
 		chunk->immutable = true;
-		bitmap_fill(chunk->populated, pcpu_unit_pages);
-		chunk->nr_populated = pcpu_unit_pages;
+		bitmap_fill(chunk->populated, chunk_pages);
+		chunk->nr_populated = chunk_pages;
+		chunk->nr_empty_pop_pages = chunk_pages;
 
 		chunk->contig_hint = chunk->free_size = dyn_size;
 		chunk->map[0] = 0;
 		chunk->map[1] = chunk->free_size | 1;
 		chunk->map_used = 1;
 
-		chunk->nr_pages = dyn_size >> PAGE_SHIFT;
+		chunk->nr_pages = chunk_pages;
 	}
 
 	/* link the first chunk in */
 	pcpu_first_chunk = chunk;
-	pcpu_nr_empty_pop_pages +=
-		pcpu_count_occupied_pages(pcpu_first_chunk, 1);
+	pcpu_nr_empty_pop_pages = pcpu_first_chunk->nr_empty_pop_pages;
 	pcpu_chunk_relocate(pcpu_first_chunk, -1);
 
 	pcpu_stats_chunk_alloc();
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
