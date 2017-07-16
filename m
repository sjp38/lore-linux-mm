Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B066F6B0599
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 22:24:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q87so129208148pfk.15
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 19:24:42 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w2si10478948plk.360.2017.07.15.19.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 19:24:41 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 06/10] percpu: modify base_addr to be region specific
Date: Sat, 15 Jul 2017 22:23:11 -0400
Message-ID: <20170716022315.19892-7-dennisz@fb.com>
In-Reply-To: <20170716022315.19892-1-dennisz@fb.com>
References: <20170716022315.19892-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Originally, the first chunk is served by up to three chunks, each given
a region they are responsible for. Despite this, the arithmetic was based
off of the base_addr making it require offsets or be overly inclusive.
This patch changes percpu checks for first chunk to consider the only
the dynamic region and the reserved check to be only the reserved
region. There is no impact here besides making these checks a little
more accurate.

This patch also adds the ground work increasing the minimum allocation
size to 4 bytes. The new field nr_pages in pcpu_chunk will be used to
keep track of the number of pages the bitmap serves. The arithmetic for
identifying first chunk and reserved chunk reflect this change.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 include/linux/percpu.h |   4 ++
 mm/percpu-internal.h   |  12 +++--
 mm/percpu.c            | 127 ++++++++++++++++++++++++++++++++++---------------
 3 files changed, 100 insertions(+), 43 deletions(-)

diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 98a371c..a5cedcd 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -21,6 +21,10 @@
 /* minimum unit size, also is the maximum supported allocation size */
 #define PCPU_MIN_UNIT_SIZE		PFN_ALIGN(32 << 10)
 
+/* minimum allocation size and shift in bytes */
+#define PCPU_MIN_ALLOC_SIZE		(1 << PCPU_MIN_ALLOC_SHIFT)
+#define PCPU_MIN_ALLOC_SHIFT		2
+
 /*
  * Percpu allocator can serve percpu allocations before slab is
  * initialized which allows slab to depend on the percpu allocator.
diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index c9158a4..56e1aba 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -23,11 +23,12 @@ struct pcpu_chunk {
 	void			*data;		/* chunk data */
 	int			first_free;	/* no free below this */
 	bool			immutable;	/* no [de]population allowed */
-	bool			has_reserved;	/* Indicates if chunk has reserved space
-						   at the beginning. Reserved chunk will
-						   contain reservation for static chunk.
-						   Dynamic chunk will contain reservation
-						   for static and reserved chunks. */
+	bool			has_reserved;	/* indicates if the region this chunk
+						   is responsible for overlaps with
+						   the prior adjacent region */
+
+	int                     nr_pages;       /* # of PAGE_SIZE pages served
+						   by this chunk */
 	int			nr_populated;	/* # of populated pages */
 	unsigned long		populated[];	/* populated bitmap */
 };
@@ -40,6 +41,7 @@ extern int pcpu_nr_empty_pop_pages;
 
 extern struct pcpu_chunk *pcpu_first_chunk;
 extern struct pcpu_chunk *pcpu_reserved_chunk;
+extern unsigned long pcpu_reserved_offset;
 
 #ifdef CONFIG_PERCPU_STATS
 
diff --git a/mm/percpu.c b/mm/percpu.c
index 7704db9..c74ad68 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -144,14 +144,14 @@ static const size_t *pcpu_group_sizes __ro_after_init;
 struct pcpu_chunk *pcpu_first_chunk __ro_after_init;
 
 /*
- * Optional reserved chunk.  This chunk reserves part of the first
- * chunk and serves it for reserved allocations.  The amount of
- * reserved offset is in pcpu_reserved_chunk_limit.  When reserved
- * area doesn't exist, the following variables contain NULL and 0
- * respectively.
+ * Optional reserved chunk.  This is the part of the first chunk that
+ * serves reserved allocations.  The pcpu_reserved_offset is the amount
+ * the pcpu_reserved_chunk->base_addr is push back into the static
+ * region for the base_addr to be page aligned.  When the reserved area
+ * doesn't exist, the following variables contain NULL and 0 respectively.
  */
 struct pcpu_chunk *pcpu_reserved_chunk __ro_after_init;
-static int pcpu_reserved_chunk_limit __ro_after_init;
+unsigned long pcpu_reserved_offset __ro_after_init;
 
 DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
 static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop, map ext */
@@ -184,19 +184,32 @@ static void pcpu_schedule_balance_work(void)
 		schedule_work(&pcpu_balance_work);
 }
 
+/*
+ * Static addresses should never be passed into the allocator.  They
+ * are accessed using the group_offsets and therefore do not rely on
+ * chunk->base_addr.
+ */
 static bool pcpu_addr_in_first_chunk(void *addr)
 {
 	void *first_start = pcpu_first_chunk->base_addr;
 
-	return addr >= first_start && addr < first_start + pcpu_unit_size;
+	return addr >= first_start &&
+	       addr < first_start +
+	       pcpu_first_chunk->nr_pages * PAGE_SIZE;
 }
 
 static bool pcpu_addr_in_reserved_chunk(void *addr)
 {
-	void *first_start = pcpu_first_chunk->base_addr;
+	void *first_start;
 
-	return addr >= first_start &&
-		addr < first_start + pcpu_reserved_chunk_limit;
+	if (!pcpu_reserved_chunk)
+		return false;
+
+	first_start = pcpu_reserved_chunk->base_addr;
+
+	return addr >= first_start + pcpu_reserved_offset &&
+	       addr < first_start +
+	       pcpu_reserved_chunk->nr_pages * PAGE_SIZE;
 }
 
 static int __pcpu_size_to_slot(int size)
@@ -237,11 +250,16 @@ static int __maybe_unused pcpu_page_idx(unsigned int cpu, int page_idx)
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
+		pcpu_unit_page_offset(cpu, page_idx);
 }
 
 static void __maybe_unused pcpu_next_unpop(struct pcpu_chunk *chunk,
@@ -737,6 +755,8 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 	chunk->free_size = pcpu_unit_size;
 	chunk->contig_hint = pcpu_unit_size;
 
+	chunk->nr_pages = pcpu_unit_pages;
+
 	return chunk;
 }
 
@@ -824,18 +844,20 @@ static int __init pcpu_verify_alloc_info(const struct pcpu_alloc_info *ai);
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
 	/* is it in the first chunk? */
-	if (pcpu_addr_in_first_chunk(addr)) {
-		/* is it in the reserved area? */
-		if (pcpu_addr_in_reserved_chunk(addr))
-			return pcpu_reserved_chunk;
+	if (pcpu_addr_in_first_chunk(addr))
 		return pcpu_first_chunk;
-	}
+	/* is it in the reserved chunk? */
+	if (pcpu_addr_in_reserved_chunk(addr))
+		return pcpu_reserved_chunk;
 
 	/*
 	 * The address is relative to unit0 which might be unused and
@@ -1366,10 +1388,17 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
 	 * The following test on unit_low/high isn't strictly
 	 * necessary but will speed up lookups of addresses which
 	 * aren't in the first chunk.
+	 *
+	 * The address check is of high granularity checking against full
+	 * chunk sizes.  pcpu_base_addr points to the beginning of the first
+	 * chunk including the static region.  This allows us to examine all
+	 * regions of the first chunk. Assumes good intent as the first
+	 * chunk may not be full (ie. < pcpu_unit_pages in size).
 	 */
-	first_low = pcpu_chunk_addr(pcpu_first_chunk, pcpu_low_unit_cpu, 0);
-	first_high = pcpu_chunk_addr(pcpu_first_chunk, pcpu_high_unit_cpu,
-				     pcpu_unit_pages);
+	first_low = (unsigned long) pcpu_base_addr +
+		    pcpu_unit_page_offset(pcpu_low_unit_cpu, 0);
+	first_high = (unsigned long) pcpu_base_addr +
+		     pcpu_unit_page_offset(pcpu_high_unit_cpu, pcpu_unit_pages);
 	if ((unsigned long)addr >= first_low &&
 	    (unsigned long)addr < first_high) {
 		for_each_possible_cpu(cpu) {
@@ -1575,6 +1604,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	unsigned int cpu;
 	int *unit_map;
 	int group, unit, i;
+	unsigned long tmp_addr, aligned_addr;
+	unsigned long map_size_bytes;
 
 #define PCPU_SETUP_BUG_ON(cond)	do {					\
 	if (unlikely(cond)) {						\
@@ -1678,46 +1709,66 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		INIT_LIST_HEAD(&pcpu_slot[i]);
 
 	/*
-	 * Initialize static chunk.  If reserved_size is zero, the
-	 * static chunk covers static area + dynamic allocation area
-	 * in the first chunk.  If reserved_size is not zero, it
-	 * covers static area + reserved area (mostly used for module
-	 * static percpu allocation).
+	 * Initialize static chunk.
+	 * The static region is dropped as those addresses are already
+	 * allocated and do not rely on chunk->base_addr.
+	 * reserved_size == 0:
+	 *      the static chunk covers the dynamic area
+	 * reserved_size > 0:
+	 *      the static chunk covers the reserved area
+	 *
+	 * If the static area is not page aligned, the region adjacent
+	 * to the static area must have its base_addr be offset into
+	 * the static area to have it be page aligned.  The overlap is
+	 * then allocated preserving the alignment in the metadata for
+	 * the actual region.
 	 */
+	tmp_addr = (unsigned long)base_addr + ai->static_size;
+	aligned_addr = tmp_addr & PAGE_MASK;
+	pcpu_reserved_offset = tmp_addr - aligned_addr;
+
+	map_size_bytes = (ai->reserved_size ?: ai->dyn_size) +
+			 pcpu_reserved_offset;
+
+	/* schunk allocation */
 	schunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
 	INIT_LIST_HEAD(&schunk->list);
 	INIT_LIST_HEAD(&schunk->map_extend_list);
-	schunk->base_addr = base_addr;
+	schunk->base_addr = (void *)aligned_addr;
 	schunk->map = smap;
 	schunk->map_alloc = ARRAY_SIZE(smap);
 	schunk->immutable = true;
 	bitmap_fill(schunk->populated, pcpu_unit_pages);
 	schunk->nr_populated = pcpu_unit_pages;
 
+	schunk->nr_pages = map_size_bytes >> PAGE_SHIFT;
+
 	if (ai->reserved_size) {
 		schunk->free_size = ai->reserved_size;
 		pcpu_reserved_chunk = schunk;
-		pcpu_reserved_chunk_limit = ai->static_size + ai->reserved_size;
 	} else {
 		schunk->free_size = dyn_size;
 		dyn_size = 0;			/* dynamic area covered */
 	}
 	schunk->contig_hint = schunk->free_size;
 
-	schunk->map[0] = 1;
-	schunk->map[1] = ai->static_size;
-	schunk->map_used = 1;
+	if (pcpu_reserved_offset) {
+		schunk->has_reserved = true;
+		schunk->map[0] = 1;
+		schunk->map[1] = pcpu_reserved_offset;
+		schunk->map_used = 1;
+	}
 	if (schunk->free_size)
-		schunk->map[++schunk->map_used] = ai->static_size + schunk->free_size;
+		schunk->map[++schunk->map_used] = map_size_bytes;
 	schunk->map[schunk->map_used] |= 1;
-	schunk->has_reserved = true;
 
 	/* init dynamic chunk if necessary */
 	if (dyn_size) {
 		dchunk = memblock_virt_alloc(pcpu_chunk_struct_size, 0);
 		INIT_LIST_HEAD(&dchunk->list);
 		INIT_LIST_HEAD(&dchunk->map_extend_list);
-		dchunk->base_addr = base_addr;
+		dchunk->base_addr = base_addr + ai->static_size +
+				    ai->reserved_size;
 		dchunk->map = dmap;
 		dchunk->map_alloc = ARRAY_SIZE(dmap);
 		dchunk->immutable = true;
@@ -1725,11 +1776,11 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		dchunk->nr_populated = pcpu_unit_pages;
 
 		dchunk->contig_hint = dchunk->free_size = dyn_size;
-		dchunk->map[0] = 1;
-		dchunk->map[1] = pcpu_reserved_chunk_limit;
-		dchunk->map[2] = (pcpu_reserved_chunk_limit + dchunk->free_size) | 1;
-		dchunk->map_used = 2;
-		dchunk->has_reserved = true;
+		dchunk->map[0] = 0;
+		dchunk->map[1] = dchunk->free_size | 1;
+		dchunk->map_used = 1;
+
+		dchunk->nr_pages = dyn_size >> PAGE_SHIFT;
 	}
 
 	/* link the first chunk in */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
