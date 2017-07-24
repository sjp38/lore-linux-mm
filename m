Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 585836B0311
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:46 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d193so163620187pgc.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:46 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x4si7488975pgc.451.2017.07.24.16.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:45 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 08/23] percpu: modify base_addr to be region specific
Date: Mon, 24 Jul 2017 19:02:05 -0400
Message-ID: <20170724230220.21774-9-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Originally, the first chunk was served by one or two chunks, each
given a region they are responsible for. Despite this, the arithmetic
was based off of the true base_addr of the chunk making it be overly
inclusive.

This patch moves the base_addr of chunks that are responsible for the
first chunk. The base_addr must remain page aligned to keep the
address alignment correct, so it is the beginning of the region served
page aligned down. start_offset holds where the region served begins
from this new base_addr.

The corresponding percpu address checks are modified to be more specific
as a result. The first chunk considers only the dynamic region and both
first chunk and reserved chunk checks ignore the static region. The
static region addresses should never be passed into the allocator. There
is no impact here besides distinguishing the first chunk and making the
checks specific.

The percpu pointer to physical address is left intact as addresses are
not given out in the non-allocated portion of percpu memory.

nr_pages is added to pcpu_chunk to keep track of the size of the entire
region served containing both start_offset and end_offset. This variable
will be used to manage the bitmap allocator.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-internal.h |   2 +
 mm/percpu.c          | 155 +++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 116 insertions(+), 41 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index f02f31c..34cb979 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -29,6 +29,8 @@ struct pcpu_chunk {
 	int			end_offset;	/* additional area required to
 						   have the region end page
 						   aligned */
+
+	int			nr_pages;	/* # of pages served by this chunk */
 	int			nr_populated;	/* # of populated pages */
 	unsigned long		populated[];	/* populated bitmap */
 };
diff --git a/mm/percpu.c b/mm/percpu.c
index e08ed61..7c9f0d3 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -181,19 +181,55 @@ static void pcpu_schedule_balance_work(void)
 		schedule_work(&pcpu_balance_work);
 }
 
+/**
+ * pcpu_addr_in_first_chunk - address check for first chunk's dynamic region
+ * @addr: percpu address of interest
+ *
+ * The first chunk is considered to be the dynamic region of the first chunk.
+ * While the true first chunk is composed of the static, dynamic, and
+ * reserved regions, it is the chunk that serves the dynamic region that is
+ * circulated in the chunk slots.
+ *
+ * The reserved chunk has a separate check and the static region addresses
+ * should never be passed into the percpu allocator.
+ *
+ * RETURNS:
+ * True if the address is in the dynamic region of the first chunk.
+ */
 static bool pcpu_addr_in_first_chunk(void *addr)
 {
-	void *first_start = pcpu_first_chunk->base_addr;
+	void *start_addr = pcpu_first_chunk->base_addr +
+			   pcpu_first_chunk->start_offset;
+	void *end_addr = pcpu_first_chunk->base_addr +
+			 pcpu_first_chunk->nr_pages * PAGE_SIZE -
+			 pcpu_first_chunk->end_offset;
 
-	return addr >= first_start && addr < first_start + pcpu_unit_size;
+	return addr >= start_addr && addr < end_addr;
 }
 
+/**
+ * pcpu_addr_in_reserved_chunk - address check for reserved region
+ *
+ * The reserved region is a part of the first chunk and primarily serves
+ * static percpu variables from kernel modules.
+ *
+ * RETURNS:
+ * True if the address is in the reserved region.
+ */
 static bool pcpu_addr_in_reserved_chunk(void *addr)
 {
-	void *first_start = pcpu_first_chunk->base_addr;
+	void *start_addr, *end_addr;
+
+	if (!pcpu_reserved_chunk)
+		return false;
 
-	return addr >= first_start &&
-		addr < first_start + pcpu_first_chunk->start_offset;
+	start_addr = pcpu_reserved_chunk->base_addr +
+		     pcpu_reserved_chunk->start_offset;
+	end_addr = pcpu_reserved_chunk->base_addr +
+		   pcpu_reserved_chunk->nr_pages * PAGE_SIZE -
+		   pcpu_reserved_chunk->end_offset;
+
+	return addr >= start_addr && addr < end_addr;
 }
 
 static int __pcpu_size_to_slot(int size)
@@ -234,11 +270,16 @@ static int __maybe_unused pcpu_page_idx(unsigned int cpu, int page_idx)
 	return pcpu_unit_map[cpu] * pcpu_unit_pages + page_idx;
 }
 
+static unsigned long pcpu_unit_page_offset(unsigned int cpu, int page_idx)
+{
+	return pcpu_unit_offsets[cpu] + (page_idx << PAGE_SHIFT);
+}
+
 static unsigned long pcpu_chunk_addr(struct pcpu_chunk *chunk,
 				     unsigned int cpu, int page_idx)
 {
-	return (unsigned long)chunk->base_addr + pcpu_unit_offsets[cpu] +
-		(page_idx << PAGE_SHIFT);
+	return (unsigned long)chunk->base_addr +
+	       pcpu_unit_page_offset(cpu, page_idx);
 }
 
 static void __maybe_unused pcpu_next_unpop(struct pcpu_chunk *chunk,
@@ -708,23 +749,34 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme,
 	pcpu_chunk_relocate(chunk, oslot);
 }
 
-static struct pcpu_chunk * __init pcpu_alloc_first_chunk(void *base_addr,
-							 int start_offset,
+static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 							 int map_size,
 							 int *map,
 							 int init_map_size)
 {
 	struct pcpu_chunk *chunk;
-	int region_size;
+	unsigned long aligned_addr;
+	int start_offset, region_size;
+
+	/* region calculations */
+	aligned_addr = tmp_addr & PAGE_MASK;
+
+	start_offset = tmp_addr - aligned_addr;
 
 	region_size = PFN_ALIGN(start_offset + map_size);
 
+	/* allocate chunk */
 	chunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
+
 	INIT_LIST_HEAD(&chunk->list);
 	INIT_LIST_HEAD(&chunk->map_extend_list);
-	chunk->base_addr = base_addr;
+
+	chunk->base_addr = (void *)aligned_addr;
 	chunk->start_offset = start_offset;
 	chunk->end_offset = region_size - chunk->start_offset - map_size;
+
+	chunk->nr_pages = pcpu_unit_pages;
+
 	chunk->map = map;
 	chunk->map_alloc = init_map_size;
 
@@ -734,10 +786,17 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(void *base_addr,
 	chunk->nr_populated = pcpu_unit_pages;
 
 	chunk->contig_hint = chunk->free_size = map_size;
-	chunk->map[0] = 1;
-	chunk->map[1] = chunk->start_offset;
-	chunk->map[2] = (chunk->start_offset + chunk->free_size) | 1;
-	chunk->map_used = 2;
+
+	if (chunk->start_offset) {
+		/* hide the beginning of the bitmap */
+		chunk->map[0] = 1;
+		chunk->map[1] = chunk->start_offset;
+		chunk->map_used = 1;
+	}
+
+	/* set chunk's free region */
+	chunk->map[++chunk->map_used] =
+		(chunk->start_offset + chunk->free_size) | 1;
 
 	if (chunk->end_offset) {
 		/* hide the end of the bitmap */
@@ -772,6 +831,8 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 	chunk->free_size = pcpu_unit_size;
 	chunk->contig_hint = pcpu_unit_size;
 
+	chunk->nr_pages = pcpu_unit_pages;
+
 	return chunk;
 }
 
@@ -859,18 +920,21 @@ static int __init pcpu_verify_alloc_info(const struct pcpu_alloc_info *ai);
  * pcpu_chunk_addr_search - determine chunk containing specified address
  * @addr: address for which the chunk needs to be determined.
  *
+ * This is an internal function that handles all but static allocations.
+ * Static percpu address values should never be passed into the allocator.
+ *
  * RETURNS:
  * The address of the found chunk.
  */
 static struct pcpu_chunk *pcpu_chunk_addr_search(void *addr)
 {
-	/* is it in the first chunk? */
-	if (pcpu_addr_in_first_chunk(addr)) {
-		/* is it in the reserved area? */
-		if (pcpu_addr_in_reserved_chunk(addr))
-			return pcpu_reserved_chunk;
+	/* is it in the dynamic region (first chunk)? */
+	if (pcpu_addr_in_first_chunk(addr))
 		return pcpu_first_chunk;
-	}
+
+	/* is it in the reserved region? */
+	if (pcpu_addr_in_reserved_chunk(addr))
+		return pcpu_reserved_chunk;
 
 	/*
 	 * The address is relative to unit0 which might be unused and
@@ -1401,10 +1465,16 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
 	 * The following test on unit_low/high isn't strictly
 	 * necessary but will speed up lookups of addresses which
 	 * aren't in the first chunk.
+	 *
+	 * The address check is against full chunk sizes.  pcpu_base_addr
+	 * points to the beginning of the first chunk including the
+	 * static region.  Assumes good intent as the first chunk may
+	 * not be full (ie. < pcpu_unit_pages in size).
 	 */
-	first_low = pcpu_chunk_addr(pcpu_first_chunk, pcpu_low_unit_cpu, 0);
-	first_high = pcpu_chunk_addr(pcpu_first_chunk, pcpu_high_unit_cpu,
-				     pcpu_unit_pages);
+	first_low = (unsigned long)pcpu_base_addr +
+		    pcpu_unit_page_offset(pcpu_low_unit_cpu, 0);
+	first_high = (unsigned long)pcpu_base_addr +
+		     pcpu_unit_page_offset(pcpu_high_unit_cpu, pcpu_unit_pages);
 	if ((unsigned long)addr >= first_low &&
 	    (unsigned long)addr < first_high) {
 		for_each_possible_cpu(cpu) {
@@ -1586,12 +1656,13 @@ static void pcpu_dump_alloc_info(const char *lvl,
  * The caller should have mapped the first chunk at @base_addr and
  * copied static data to each unit.
  *
- * If the first chunk ends up with both reserved and dynamic areas, it
- * is served by two chunks - one to serve the core static and reserved
- * areas and the other for the dynamic area.  They share the same vm
- * and page map but uses different area allocation map to stay away
- * from each other.  The latter chunk is circulated in the chunk slots
- * and available for dynamic allocation like any other chunks.
+ * The first chunk will always contain a static and a dynamic region.
+ * However, the static region is not managed by any chunk.  If the first
+ * chunk also contains a reserved region, it is served by two chunks -
+ * one for the reserved region and one for the dynamic region.  They
+ * share the same vm, but use offset regions in the area allocation map.
+ * The chunk serving the dynamic region is circulated in the chunk slots
+ * and available for dynamic allocation like any other chunk.
  *
  * RETURNS:
  * 0 on success, -errno on failure.
@@ -1609,7 +1680,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	unsigned int cpu;
 	int *unit_map;
 	int group, unit, i;
-	int map_size, start_offset;
+	int map_size;
+	unsigned long tmp_addr;
 
 #define PCPU_SETUP_BUG_ON(cond)	do {					\
 	if (unlikely(cond)) {						\
@@ -1712,25 +1784,26 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		INIT_LIST_HEAD(&pcpu_slot[i]);
 
 	/*
-	 * Initialize static chunk.  If reserved_size is zero, the
-	 * static chunk covers static area + dynamic allocation area
-	 * in the first chunk.  If reserved_size is not zero, it
-	 * covers static area + reserved area (mostly used for module
-	 * static percpu allocation).
+	 * Initialize first chunk.
+	 * If the reserved_size is non-zero, this initializes the reserved
+	 * chunk.  If the reserved_size is zero, the reserved chunk is NULL
+	 * and the dynamic region is initialized here.  The first chunk,
+	 * pcpu_first_chunk, will always point to the chunk that serves
+	 * the dynamic region.
 	 */
-	start_offset = ai->static_size;
+	tmp_addr = (unsigned long)base_addr + ai->static_size;
 	map_size = ai->reserved_size ?: ai->dyn_size;
-	chunk = pcpu_alloc_first_chunk(base_addr, start_offset, map_size, smap,
+	chunk = pcpu_alloc_first_chunk(tmp_addr, map_size, smap,
 				       ARRAY_SIZE(smap));
 
 	/* init dynamic chunk if necessary */
 	if (ai->reserved_size) {
 		pcpu_reserved_chunk = chunk;
 
-		start_offset = ai->static_size + ai->reserved_size;
+		tmp_addr = (unsigned long)base_addr + ai->static_size +
+			   ai->reserved_size;
 		map_size = ai->dyn_size;
-		chunk = pcpu_alloc_first_chunk(base_addr, start_offset,
-					       map_size, dmap,
+		chunk = pcpu_alloc_first_chunk(tmp_addr, map_size, dmap,
 					       ARRAY_SIZE(dmap));
 	}
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
