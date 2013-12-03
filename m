Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id BD48D6B008C
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:29:06 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so9510705yhl.20
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:29:06 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id r46si40906789yhm.47.2013.12.02.18.29.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 18:29:05 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v2 18/23] mm/percpu: Use memblock apis for early memory allocations
Date: Mon, 2 Dec 2013 21:27:33 -0500
Message-ID: <1386037658-3161-19-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock. And the
archs which still uses bootmem, these new apis just fallback to exiting
bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/percpu.c |   41 +++++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 16 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 0d10def..f74902c 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1063,7 +1063,7 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
 			  __alignof__(ai->groups[0].cpu_map[0]));
 	ai_size = base_size + nr_units * sizeof(ai->groups[0].cpu_map[0]);
 
-	ptr = alloc_bootmem_nopanic(PFN_ALIGN(ai_size));
+	ptr = memblock_virt_alloc_nopanic(PFN_ALIGN(ai_size));
 	if (!ptr)
 		return NULL;
 	ai = ptr;
@@ -1088,7 +1088,7 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
  */
 void __init pcpu_free_alloc_info(struct pcpu_alloc_info *ai)
 {
-	free_bootmem(__pa(ai), ai->__ai_size);
+	memblock_free_early(__pa(ai), ai->__ai_size);
 }
 
 /**
@@ -1246,10 +1246,12 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
 	/* process group information and build config tables accordingly */
-	group_offsets = alloc_bootmem(ai->nr_groups * sizeof(group_offsets[0]));
-	group_sizes = alloc_bootmem(ai->nr_groups * sizeof(group_sizes[0]));
-	unit_map = alloc_bootmem(nr_cpu_ids * sizeof(unit_map[0]));
-	unit_off = alloc_bootmem(nr_cpu_ids * sizeof(unit_off[0]));
+	group_offsets = memblock_virt_alloc(ai->nr_groups *
+					     sizeof(group_offsets[0]));
+	group_sizes = memblock_virt_alloc(ai->nr_groups *
+					   sizeof(group_sizes[0]));
+	unit_map = memblock_virt_alloc(nr_cpu_ids * sizeof(unit_map[0]));
+	unit_off = memblock_virt_alloc(nr_cpu_ids * sizeof(unit_off[0]));
 
 	for (cpu = 0; cpu < nr_cpu_ids; cpu++)
 		unit_map[cpu] = UINT_MAX;
@@ -1311,7 +1313,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 * empty chunks.
 	 */
 	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
-	pcpu_slot = alloc_bootmem(pcpu_nr_slots * sizeof(pcpu_slot[0]));
+	pcpu_slot = memblock_virt_alloc(pcpu_nr_slots * sizeof(pcpu_slot[0]));
 	for (i = 0; i < pcpu_nr_slots; i++)
 		INIT_LIST_HEAD(&pcpu_slot[i]);
 
@@ -1322,7 +1324,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 * covers static area + reserved area (mostly used for module
 	 * static percpu allocation).
 	 */
-	schunk = alloc_bootmem(pcpu_chunk_struct_size);
+	schunk = memblock_virt_alloc(pcpu_chunk_struct_size);
 	INIT_LIST_HEAD(&schunk->list);
 	schunk->base_addr = base_addr;
 	schunk->map = smap;
@@ -1346,7 +1348,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 
 	/* init dynamic chunk if necessary */
 	if (dyn_size) {
-		dchunk = alloc_bootmem(pcpu_chunk_struct_size);
+		dchunk = memblock_virt_alloc(pcpu_chunk_struct_size);
 		INIT_LIST_HEAD(&dchunk->list);
 		dchunk->base_addr = base_addr;
 		dchunk->map = dmap;
@@ -1626,7 +1628,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
 	areas_size = PFN_ALIGN(ai->nr_groups * sizeof(void *));
 
-	areas = alloc_bootmem_nopanic(areas_size);
+	areas = memblock_virt_alloc_nopanic(areas_size);
 	if (!areas) {
 		rc = -ENOMEM;
 		goto out_free;
@@ -1712,7 +1714,7 @@ out_free_areas:
 out_free:
 	pcpu_free_alloc_info(ai);
 	if (areas)
-		free_bootmem(__pa(areas), areas_size);
+		memblock_free_early(__pa(areas), areas_size);
 	return rc;
 }
 #endif /* BUILD_EMBED_FIRST_CHUNK */
@@ -1760,7 +1762,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	/* unaligned allocations can't be freed, round up to page size */
 	pages_size = PFN_ALIGN(unit_pages * num_possible_cpus() *
 			       sizeof(pages[0]));
-	pages = alloc_bootmem(pages_size);
+	pages = memblock_virt_alloc(pages_size);
 
 	/* allocate pages */
 	j = 0;
@@ -1823,7 +1825,7 @@ enomem:
 		free_fn(page_address(pages[j]), PAGE_SIZE);
 	rc = -ENOMEM;
 out_free_ar:
-	free_bootmem(__pa(pages), pages_size);
+	memblock_free_early(__pa(pages), pages_size);
 	pcpu_free_alloc_info(ai);
 	return rc;
 }
@@ -1848,12 +1850,15 @@ EXPORT_SYMBOL(__per_cpu_offset);
 static void * __init pcpu_dfl_fc_alloc(unsigned int cpu, size_t size,
 				       size_t align)
 {
-	return __alloc_bootmem_nopanic(size, align, __pa(MAX_DMA_ADDRESS));
+	return  memblock_virt_alloc_try_nid_nopanic(size, align,
+						     __pa(MAX_DMA_ADDRESS),
+						     BOOTMEM_ALLOC_ACCESSIBLE,
+						     MAX_NUMNODES);
 }
 
 static void __init pcpu_dfl_fc_free(void *ptr, size_t size)
 {
-	free_bootmem(__pa(ptr), size);
+	memblock_free_early(__pa(ptr), size);
 }
 
 void __init setup_per_cpu_areas(void)
@@ -1896,7 +1901,11 @@ void __init setup_per_cpu_areas(void)
 	void *fc;
 
 	ai = pcpu_alloc_alloc_info(1, 1);
-	fc = __alloc_bootmem(unit_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+	fc = memblock_virt_alloc_try_nid_nopanic(unit_size,
+						 PAGE_SIZE,
+						 __pa(MAX_DMA_ADDRESS),
+						 BOOTMEM_ALLOC_ACCESSIBLE,
+						 MAX_NUMNODES);
 	if (!ai || !fc)
 		panic("Failed to allocate memory for percpu areas.");
 	/* kmemleak tracks the percpu allocations separately */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
