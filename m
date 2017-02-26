Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9866B0038
	for <linux-mm@kvack.org>; Sat, 25 Feb 2017 23:39:06 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d18so116891973pgh.2
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 20:39:06 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id m8si8397086pln.122.2017.02.25.20.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Feb 2017 20:39:04 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id o64so2587285pfb.0
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 20:39:04 -0800 (PST)
From: Tahsin Erdogan <tahsin@google.com>
Subject: [PATCH v2 3/3] percpu: improve allocation success rate for non-GFP_KERNEL callers
Date: Sat, 25 Feb 2017 20:38:29 -0800
Message-Id: <20170226043829.14270-1-tahsin@google.com>
In-Reply-To: <201702260805.zhem8KFI%fengguang.wu@intel.com>
References: <201702260805.zhem8KFI%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tahsin Erdogan <tahsin@google.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

When pcpu_alloc() is called with gfp != GFP_KERNEL, the likelihood of
a failure is higher than GFP_KERNEL case. This is mainly because
pcpu_alloc() relies on previously allocated reserves and does not make
an effort to add memory to its pools for non-GFP_KERNEL case.

This issue is somewhat mitigated by kicking off a background work when
a memory allocation failure occurs. But this doesn't really help the
original victim of allocation failure.

This problem affects blkg_lookup_create() callers on machines with a
lot of cpus.

This patch reduces failure cases by trying to expand the memory pools.
It passes along gfp flag so it is safe to allocate memory this way.

To make this work, a gfp flag aware vmalloc_gfp() function is added.
Also, locking around vmap_area_lock has been updated to save/restore
irq flags. This was needed to avoid a lockdep problem between
request_queue->queue_lock and vmap_area_lock.

Signed-off-by: Tahsin Erdogan <tahsin@google.com>
---
v2:
 added vmalloc_gfp() to mm/nommu.c as well

 include/linux/vmalloc.h |   5 +-
 mm/nommu.c              |   5 ++
 mm/percpu-km.c          |   8 +--
 mm/percpu-vm.c          | 119 +++++++++++-------------------------
 mm/percpu.c             | 156 ++++++++++++++++++++++++++++--------------------
 mm/vmalloc.c            |  74 ++++++++++++++---------
 6 files changed, 184 insertions(+), 183 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index d68edffbf142..8110a0040b9d 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -72,6 +72,7 @@ extern void *vzalloc(unsigned long size);
 extern void *vmalloc_user(unsigned long size);
 extern void *vmalloc_node(unsigned long size, int node);
 extern void *vzalloc_node(unsigned long size, int node);
+extern void *vmalloc_gfp(unsigned long size, gfp_t gfp_mask);
 extern void *vmalloc_exec(unsigned long size);
 extern void *vmalloc_32(unsigned long size);
 extern void *vmalloc_32_user(unsigned long size);
@@ -165,14 +166,14 @@ extern __init void vm_area_register_early(struct vm_struct *vm, size_t align);
 # ifdef CONFIG_MMU
 struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 				     const size_t *sizes, int nr_vms,
-				     size_t align);
+				     size_t align, gfp_t gfp_mask);
 
 void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms);
 # else
 static inline struct vm_struct **
 pcpu_get_vm_areas(const unsigned long *offsets,
 		const size_t *sizes, int nr_vms,
-		size_t align)
+		size_t align, gfp_t gfp_mask)
 {
 	return NULL;
 }
diff --git a/mm/nommu.c b/mm/nommu.c
index bc964c26be8c..e81d4724ac07 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -359,6 +359,11 @@ void *vzalloc_node(unsigned long size, int node)
 }
 EXPORT_SYMBOL(vzalloc_node);
 
+void *vmalloc_gfp(unsigned long size, gfp_t gfp_mask)
+{
+	return __vmalloc(size, gfp_mask, PAGE_KERNEL);
+}
+
 #ifndef PAGE_KERNEL_EXEC
 # define PAGE_KERNEL_EXEC PAGE_KERNEL
 #endif
diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index d66911ff42d9..599a9ce84544 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -34,7 +34,7 @@
 #include <linux/log2.h>
 
 static int pcpu_populate_chunk(struct pcpu_chunk *chunk,
-			       int page_start, int page_end)
+			       int page_start, int page_end, gfp_t gfp)
 {
 	return 0;
 }
@@ -45,18 +45,18 @@ static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk,
 	/* nada */
 }
 
-static struct pcpu_chunk *pcpu_create_chunk(void)
+static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 {
 	const int nr_pages = pcpu_group_sizes[0] >> PAGE_SHIFT;
 	struct pcpu_chunk *chunk;
 	struct page *pages;
 	int i;
 
-	chunk = pcpu_alloc_chunk();
+	chunk = pcpu_alloc_chunk(gfp);
 	if (!chunk)
 		return NULL;
 
-	pages = alloc_pages(GFP_KERNEL, order_base_2(nr_pages));
+	pages = alloc_pages(gfp, order_base_2(nr_pages));
 	if (!pages) {
 		pcpu_free_chunk(chunk);
 		return NULL;
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index 9ac639499bd1..42348a421ccf 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -20,28 +20,6 @@ static struct page *pcpu_chunk_page(struct pcpu_chunk *chunk,
 }
 
 /**
- * pcpu_get_pages - get temp pages array
- *
- * Returns pointer to array of pointers to struct page which can be indexed
- * with pcpu_page_idx().  Note that there is only one array and accesses
- * should be serialized by pcpu_alloc_mutex.
- *
- * RETURNS:
- * Pointer to temp pages array on success.
- */
-static struct page **pcpu_get_pages(void)
-{
-	static struct page **pages;
-	size_t pages_size = pcpu_nr_units * pcpu_unit_pages * sizeof(pages[0]);
-
-	lockdep_assert_held(&pcpu_alloc_mutex);
-
-	if (!pages)
-		pages = pcpu_mem_zalloc(pages_size);
-	return pages;
-}
-
-/**
  * pcpu_free_pages - free pages which were allocated for @chunk
  * @chunk: chunk pages were allocated for
  * @pages: array of pages to be freed, indexed by pcpu_page_idx()
@@ -73,15 +51,16 @@ static void pcpu_free_pages(struct pcpu_chunk *chunk,
  * @pages: array to put the allocated pages into, indexed by pcpu_page_idx()
  * @page_start: page index of the first page to be allocated
  * @page_end: page index of the last page to be allocated + 1
+ * @gfp: gfp flags
  *
  * Allocate pages [@page_start,@page_end) into @pages for all units.
  * The allocation is for @chunk.  Percpu core doesn't care about the
  * content of @pages and will pass it verbatim to pcpu_map_pages().
  */
 static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
-			    struct page **pages, int page_start, int page_end)
+			    struct page **pages, int page_start, int page_end,
+			    gfp_t gfp)
 {
-	const gfp_t gfp = GFP_KERNEL | __GFP_HIGHMEM | __GFP_COLD;
 	unsigned int cpu, tcpu;
 	int i;
 
@@ -135,38 +114,6 @@ static void __pcpu_unmap_pages(unsigned long addr, int nr_pages)
 }
 
 /**
- * pcpu_unmap_pages - unmap pages out of a pcpu_chunk
- * @chunk: chunk of interest
- * @pages: pages array which can be used to pass information to free
- * @page_start: page index of the first page to unmap
- * @page_end: page index of the last page to unmap + 1
- *
- * For each cpu, unmap pages [@page_start,@page_end) out of @chunk.
- * Corresponding elements in @pages were cleared by the caller and can
- * be used to carry information to pcpu_free_pages() which will be
- * called after all unmaps are finished.  The caller should call
- * proper pre/post flush functions.
- */
-static void pcpu_unmap_pages(struct pcpu_chunk *chunk,
-			     struct page **pages, int page_start, int page_end)
-{
-	unsigned int cpu;
-	int i;
-
-	for_each_possible_cpu(cpu) {
-		for (i = page_start; i < page_end; i++) {
-			struct page *page;
-
-			page = pcpu_chunk_page(chunk, cpu, i);
-			WARN_ON(!page);
-			pages[pcpu_page_idx(cpu, i)] = page;
-		}
-		__pcpu_unmap_pages(pcpu_chunk_addr(chunk, cpu, page_start),
-				   page_end - page_start);
-	}
-}
-
-/**
  * pcpu_post_unmap_tlb_flush - flush TLB after unmapping
  * @chunk: pcpu_chunk the regions to be flushed belong to
  * @page_start: page index of the first page to be flushed
@@ -262,32 +209,38 @@ static void pcpu_post_map_flush(struct pcpu_chunk *chunk,
  * @chunk: chunk of interest
  * @page_start: the start page
  * @page_end: the end page
+ * @gfp: gfp flags
  *
  * For each cpu, populate and map pages [@page_start,@page_end) into
  * @chunk.
- *
- * CONTEXT:
- * pcpu_alloc_mutex, does GFP_KERNEL allocation.
  */
 static int pcpu_populate_chunk(struct pcpu_chunk *chunk,
-			       int page_start, int page_end)
+			       int page_start, int page_end, gfp_t gfp)
 {
 	struct page **pages;
+	size_t pages_size = pcpu_nr_units * pcpu_unit_pages * sizeof(pages[0]);
+	int ret;
 
-	pages = pcpu_get_pages();
+	pages = pcpu_mem_zalloc(pages_size, gfp);
 	if (!pages)
 		return -ENOMEM;
 
-	if (pcpu_alloc_pages(chunk, pages, page_start, page_end))
-		return -ENOMEM;
+	if (pcpu_alloc_pages(chunk, pages, page_start, page_end,
+			     gfp | __GFP_HIGHMEM | __GFP_COLD)) {
+		ret = -ENOMEM;
+		goto out;
+	}
 
 	if (pcpu_map_pages(chunk, pages, page_start, page_end)) {
 		pcpu_free_pages(chunk, pages, page_start, page_end);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out;
 	}
 	pcpu_post_map_flush(chunk, page_start, page_end);
-
-	return 0;
+	ret = 0;
+out:
+	pcpu_mem_free(pages);
+	return ret;
 }
 
 /**
@@ -298,44 +251,40 @@ static int pcpu_populate_chunk(struct pcpu_chunk *chunk,
  *
  * For each cpu, depopulate and unmap pages [@page_start,@page_end)
  * from @chunk.
- *
- * CONTEXT:
- * pcpu_alloc_mutex.
  */
 static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk,
 				  int page_start, int page_end)
 {
-	struct page **pages;
-
-	/*
-	 * If control reaches here, there must have been at least one
-	 * successful population attempt so the temp pages array must
-	 * be available now.
-	 */
-	pages = pcpu_get_pages();
-	BUG_ON(!pages);
+	unsigned int cpu;
+	int i;
 
-	/* unmap and free */
 	pcpu_pre_unmap_flush(chunk, page_start, page_end);
 
-	pcpu_unmap_pages(chunk, pages, page_start, page_end);
+	for_each_possible_cpu(cpu)
+		for (i = page_start; i < page_end; i++) {
+			struct page *page;
+
+			page = pcpu_chunk_page(chunk, cpu, i);
+			WARN_ON(!page);
 
-	/* no need to flush tlb, vmalloc will handle it lazily */
+			__pcpu_unmap_pages(pcpu_chunk_addr(chunk, cpu, i), 1);
 
-	pcpu_free_pages(chunk, pages, page_start, page_end);
+			if (likely(page))
+				__free_page(page);
+		}
 }
 
-static struct pcpu_chunk *pcpu_create_chunk(void)
+static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 {
 	struct pcpu_chunk *chunk;
 	struct vm_struct **vms;
 
-	chunk = pcpu_alloc_chunk();
+	chunk = pcpu_alloc_chunk(gfp);
 	if (!chunk)
 		return NULL;
 
 	vms = pcpu_get_vm_areas(pcpu_group_offsets, pcpu_group_sizes,
-				pcpu_nr_groups, pcpu_atom_size);
+				pcpu_nr_groups, pcpu_atom_size, gfp);
 	if (!vms) {
 		pcpu_free_chunk(chunk);
 		return NULL;
diff --git a/mm/percpu.c b/mm/percpu.c
index 232356a2d914..f2cee0ae8688 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -103,6 +103,11 @@
 #define __pcpu_ptr_to_addr(ptr)		(void __force *)(ptr)
 #endif	/* CONFIG_SMP */
 
+#define PCPU_BUSY_EXPAND_MAP		1	/* pcpu_alloc() is expanding the
+						 * the map
+						 */
+#define PCPU_BUSY_POPULATE_CHUNK	2	/* chunk is being populated */
+
 struct pcpu_chunk {
 	struct list_head	list;		/* linked to pcpu_slot lists */
 	int			free_size;	/* free bytes in the chunk */
@@ -118,6 +123,7 @@ struct pcpu_chunk {
 	int			first_free;	/* no free below this */
 	bool			immutable;	/* no [de]population allowed */
 	int			nr_populated;	/* # of populated pages */
+	int			busy_flags;	/* type of work in progress */
 	unsigned long		populated[];	/* populated bitmap */
 };
 
@@ -162,7 +168,6 @@ static struct pcpu_chunk *pcpu_reserved_chunk;
 static int pcpu_reserved_chunk_limit;
 
 static DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
-static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop, map ext */
 
 static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
 
@@ -282,29 +287,31 @@ static void __maybe_unused pcpu_next_pop(struct pcpu_chunk *chunk,
 	     (rs) < (re);						    \
 	     (rs) = (re) + 1, pcpu_next_pop((chunk), &(rs), &(re), (end)))
 
+static bool pcpu_has_unpop_pages(struct pcpu_chunk *chunk, int start, int end)
+{
+	return find_next_zero_bit(chunk->populated, end, start) < end;
+}
+
 /**
  * pcpu_mem_zalloc - allocate memory
  * @size: bytes to allocate
  *
  * Allocate @size bytes.  If @size is smaller than PAGE_SIZE,
- * kzalloc() is used; otherwise, vzalloc() is used.  The returned
+ * kzalloc() is used; otherwise, vmalloc_gfp() is used.  The returned
  * memory is always zeroed.
  *
- * CONTEXT:
- * Does GFP_KERNEL allocation.
- *
  * RETURNS:
  * Pointer to the allocated area on success, NULL on failure.
  */
-static void *pcpu_mem_zalloc(size_t size)
+static void *pcpu_mem_zalloc(size_t size, gfp_t gfp)
 {
 	if (WARN_ON_ONCE(!slab_is_available()))
 		return NULL;
 
 	if (size <= PAGE_SIZE)
-		return kzalloc(size, GFP_KERNEL);
+		return kzalloc(size, gfp);
 	else
-		return vzalloc(size);
+		return vmalloc_gfp(size, gfp | __GFP_HIGHMEM | __GFP_ZERO);
 }
 
 /**
@@ -438,15 +445,14 @@ static int pcpu_need_to_extend(struct pcpu_chunk *chunk, bool is_atomic)
  * RETURNS:
  * 0 on success, -errno on failure.
  */
-static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc)
+static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc,
+				gfp_t gfp)
 {
 	int *old = NULL, *new = NULL;
 	size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
 	unsigned long flags;
 
-	lockdep_assert_held(&pcpu_alloc_mutex);
-
-	new = pcpu_mem_zalloc(new_size);
+	new = pcpu_mem_zalloc(new_size, gfp);
 	if (!new)
 		return -ENOMEM;
 
@@ -716,16 +722,16 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme,
 	pcpu_chunk_relocate(chunk, oslot);
 }
 
-static struct pcpu_chunk *pcpu_alloc_chunk(void)
+static struct pcpu_chunk *pcpu_alloc_chunk(gfp_t gfp)
 {
 	struct pcpu_chunk *chunk;
 
-	chunk = pcpu_mem_zalloc(pcpu_chunk_struct_size);
+	chunk = pcpu_mem_zalloc(pcpu_chunk_struct_size, gfp);
 	if (!chunk)
 		return NULL;
 
 	chunk->map = pcpu_mem_zalloc(PCPU_DFL_MAP_ALLOC *
-						sizeof(chunk->map[0]));
+						sizeof(chunk->map[0]), gfp);
 	if (!chunk->map) {
 		pcpu_mem_free(chunk);
 		return NULL;
@@ -811,9 +817,10 @@ static void pcpu_chunk_depopulated(struct pcpu_chunk *chunk,
  * pcpu_addr_to_page		- translate address to physical address
  * pcpu_verify_alloc_info	- check alloc_info is acceptable during init
  */
-static int pcpu_populate_chunk(struct pcpu_chunk *chunk, int off, int size);
+static int pcpu_populate_chunk(struct pcpu_chunk *chunk, int off, int size,
+			       gfp_t gfp);
 static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk, int off, int size);
-static struct pcpu_chunk *pcpu_create_chunk(void);
+static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp);
 static void pcpu_destroy_chunk(struct pcpu_chunk *chunk);
 static struct page *pcpu_addr_to_page(void *addr);
 static int __init pcpu_verify_alloc_info(const struct pcpu_alloc_info *ai);
@@ -874,6 +881,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
 	int occ_pages = 0;
 	int slot, off, new_alloc, cpu, ret;
+	int page_start, page_end;
 	unsigned long flags;
 	void __percpu *ptr;
 
@@ -893,9 +901,6 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		return NULL;
 	}
 
-	if (!is_atomic)
-		mutex_lock(&pcpu_alloc_mutex);
-
 	spin_lock_irqsave(&pcpu_lock, flags);
 
 	/* serve reserved allocations from the reserved chunk if available */
@@ -909,8 +914,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 		while ((new_alloc = pcpu_need_to_extend(chunk, is_atomic))) {
 			spin_unlock_irqrestore(&pcpu_lock, flags);
-			if (is_atomic ||
-			    pcpu_extend_area_map(chunk, new_alloc) < 0) {
+			if (pcpu_extend_area_map(chunk, new_alloc, gfp) < 0) {
 				err = "failed to extend area map of reserved chunk";
 				goto fail;
 			}
@@ -933,17 +937,24 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 			if (size > chunk->contig_hint)
 				continue;
 
+			if (chunk->busy_flags & PCPU_BUSY_POPULATE_CHUNK)
+				continue;
+
 			new_alloc = pcpu_need_to_extend(chunk, is_atomic);
 			if (new_alloc) {
-				if (is_atomic)
-					continue;
+				chunk->busy_flags |= PCPU_BUSY_EXPAND_MAP;
 				spin_unlock_irqrestore(&pcpu_lock, flags);
-				if (pcpu_extend_area_map(chunk,
-							 new_alloc) < 0) {
+
+				ret = pcpu_extend_area_map(chunk, new_alloc,
+							   gfp);
+				spin_lock_irqsave(&pcpu_lock, flags);
+				chunk->busy_flags &= ~PCPU_BUSY_EXPAND_MAP;
+				if (ret < 0) {
+					spin_unlock_irqrestore(&pcpu_lock,
+							       flags);
 					err = "failed to extend area map";
 					goto fail;
 				}
-				spin_lock_irqsave(&pcpu_lock, flags);
 				/*
 				 * pcpu_lock has been dropped, need to
 				 * restart cpu_slot list walking.
@@ -953,53 +964,59 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 			off = pcpu_alloc_area(chunk, size, align, is_atomic,
 					      &occ_pages);
+			if (off < 0 && is_atomic) {
+				/* Try non-populated areas. */
+				off = pcpu_alloc_area(chunk, size, align, false,
+						      &occ_pages);
+			}
+
 			if (off >= 0)
 				goto area_found;
 		}
 	}
 
+	WARN_ON(!list_empty(&pcpu_slot[pcpu_nr_slots - 1]));
+
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 
-	/*
-	 * No space left.  Create a new chunk.  We don't want multiple
-	 * tasks to create chunks simultaneously.  Serialize and create iff
-	 * there's still no empty chunk after grabbing the mutex.
-	 */
-	if (is_atomic)
+	chunk = pcpu_create_chunk(gfp);
+	if (!chunk) {
+		err = "failed to allocate new chunk";
 		goto fail;
+	}
 
-	if (list_empty(&pcpu_slot[pcpu_nr_slots - 1])) {
-		chunk = pcpu_create_chunk();
-		if (!chunk) {
-			err = "failed to allocate new chunk";
-			goto fail;
-		}
+	spin_lock_irqsave(&pcpu_lock, flags);
 
-		spin_lock_irqsave(&pcpu_lock, flags);
+	/* Check whether someone else added a chunk while lock was
+	 * dropped.
+	 */
+	if (list_empty(&pcpu_slot[pcpu_nr_slots - 1]))
 		pcpu_chunk_relocate(chunk, -1);
-	} else {
-		spin_lock_irqsave(&pcpu_lock, flags);
-	}
+	else
+		pcpu_destroy_chunk(chunk);
 
 	goto restart;
 
 area_found:
-	spin_unlock_irqrestore(&pcpu_lock, flags);
+
+	page_start = PFN_DOWN(off);
+	page_end = PFN_UP(off + size);
 
 	/* populate if not all pages are already there */
-	if (!is_atomic) {
-		int page_start, page_end, rs, re;
+	if (pcpu_has_unpop_pages(chunk, page_start, page_end)) {
+		int rs, re;
 
-		page_start = PFN_DOWN(off);
-		page_end = PFN_UP(off + size);
+		chunk->busy_flags |= PCPU_BUSY_POPULATE_CHUNK;
+		spin_unlock_irqrestore(&pcpu_lock, flags);
 
 		pcpu_for_each_unpop_region(chunk, rs, re, page_start, page_end) {
 			WARN_ON(chunk->immutable);
 
-			ret = pcpu_populate_chunk(chunk, rs, re);
+			ret = pcpu_populate_chunk(chunk, rs, re, gfp);
 
 			spin_lock_irqsave(&pcpu_lock, flags);
 			if (ret) {
+				chunk->busy_flags &= ~PCPU_BUSY_POPULATE_CHUNK;
 				pcpu_free_area(chunk, off, &occ_pages);
 				err = "failed to populate";
 				goto fail_unlock;
@@ -1008,18 +1025,18 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 			spin_unlock_irqrestore(&pcpu_lock, flags);
 		}
 
-		mutex_unlock(&pcpu_alloc_mutex);
+		spin_lock_irqsave(&pcpu_lock, flags);
+		chunk->busy_flags &= ~PCPU_BUSY_POPULATE_CHUNK;
 	}
 
-	if (chunk != pcpu_reserved_chunk) {
-		spin_lock_irqsave(&pcpu_lock, flags);
+	if (chunk != pcpu_reserved_chunk)
 		pcpu_nr_empty_pop_pages -= occ_pages;
-		spin_unlock_irqrestore(&pcpu_lock, flags);
-	}
 
 	if (pcpu_nr_empty_pop_pages < PCPU_EMPTY_POP_PAGES_LOW)
 		pcpu_schedule_balance_work();
 
+	spin_unlock_irqrestore(&pcpu_lock, flags);
+
 	/* clear the areas and return address relative to base address */
 	for_each_possible_cpu(cpu)
 		memset((void *)pcpu_chunk_addr(chunk, cpu, 0) + off, 0, size);
@@ -1042,8 +1059,6 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 		/* see the flag handling in pcpu_blance_workfn() */
 		pcpu_atomic_alloc_failed = true;
 		pcpu_schedule_balance_work();
-	} else {
-		mutex_unlock(&pcpu_alloc_mutex);
 	}
 	return NULL;
 }
@@ -1118,7 +1133,6 @@ static void pcpu_balance_workfn(struct work_struct *work)
 	 * There's no reason to keep around multiple unused chunks and VM
 	 * areas can be scarce.  Destroy all free chunks except for one.
 	 */
-	mutex_lock(&pcpu_alloc_mutex);
 	spin_lock_irq(&pcpu_lock);
 
 	list_for_each_entry_safe(chunk, next, free_head, list) {
@@ -1128,6 +1142,10 @@ static void pcpu_balance_workfn(struct work_struct *work)
 		if (chunk == list_first_entry(free_head, struct pcpu_chunk, list))
 			continue;
 
+		if (chunk->busy_flags & (PCPU_BUSY_POPULATE_CHUNK |
+					 PCPU_BUSY_EXPAND_MAP))
+			continue;
+
 		list_del_init(&chunk->map_extend_list);
 		list_move(&chunk->list, &to_free);
 	}
@@ -1162,7 +1180,7 @@ static void pcpu_balance_workfn(struct work_struct *work)
 		spin_unlock_irq(&pcpu_lock);
 
 		if (new_alloc)
-			pcpu_extend_area_map(chunk, new_alloc);
+			pcpu_extend_area_map(chunk, new_alloc, GFP_KERNEL);
 	} while (chunk);
 
 	/*
@@ -1194,20 +1212,29 @@ static void pcpu_balance_workfn(struct work_struct *work)
 
 		spin_lock_irq(&pcpu_lock);
 		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
+			if (chunk->busy_flags & PCPU_BUSY_POPULATE_CHUNK)
+				continue;
 			nr_unpop = pcpu_unit_pages - chunk->nr_populated;
 			if (nr_unpop)
 				break;
 		}
+
+		if (nr_unpop)
+			chunk->busy_flags |= PCPU_BUSY_POPULATE_CHUNK;
+
 		spin_unlock_irq(&pcpu_lock);
 
 		if (!nr_unpop)
 			continue;
 
-		/* @chunk can't go away while pcpu_alloc_mutex is held */
+		/* @chunk can't go away because only pcpu_balance_workfn
+		 * destroys it.
+		 */
 		pcpu_for_each_unpop_region(chunk, rs, re, 0, pcpu_unit_pages) {
 			int nr = min(re - rs, nr_to_pop);
 
-			ret = pcpu_populate_chunk(chunk, rs, rs + nr);
+			ret = pcpu_populate_chunk(chunk, rs, rs + nr,
+						  GFP_KERNEL);
 			if (!ret) {
 				nr_to_pop -= nr;
 				spin_lock_irq(&pcpu_lock);
@@ -1220,11 +1247,14 @@ static void pcpu_balance_workfn(struct work_struct *work)
 			if (!nr_to_pop)
 				break;
 		}
+		spin_lock_irq(&pcpu_lock);
+		chunk->busy_flags &= ~PCPU_BUSY_POPULATE_CHUNK;
+		spin_unlock_irq(&pcpu_lock);
 	}
 
 	if (nr_to_pop) {
 		/* ran out of chunks to populate, create a new one and retry */
-		chunk = pcpu_create_chunk();
+		chunk = pcpu_create_chunk(GFP_KERNEL);
 		if (chunk) {
 			spin_lock_irq(&pcpu_lock);
 			pcpu_chunk_relocate(chunk, -1);
@@ -1232,8 +1262,6 @@ static void pcpu_balance_workfn(struct work_struct *work)
 			goto retry_pop;
 		}
 	}
-
-	mutex_unlock(&pcpu_alloc_mutex);
 }
 
 /**
@@ -2297,7 +2325,7 @@ void __init percpu_init_late(void)
 
 		BUILD_BUG_ON(size > PAGE_SIZE);
 
-		map = pcpu_mem_zalloc(size);
+		map = pcpu_mem_zalloc(size, GFP_KERNEL);
 		BUG_ON(!map);
 
 		spin_lock_irqsave(&pcpu_lock, flags);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d89034a393f2..01abc9ed5224 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -360,6 +360,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	unsigned long addr;
 	int purged = 0;
 	struct vmap_area *first;
+	unsigned long flags;
 
 	BUG_ON(!size);
 	BUG_ON(offset_in_page(size));
@@ -379,7 +380,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	kmemleak_scan_area(&va->rb_node, SIZE_MAX, gfp_mask & GFP_RECLAIM_MASK);
 
 retry:
-	spin_lock(&vmap_area_lock);
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	/*
 	 * Invalidate cache if we have more permissive parameters.
 	 * cached_hole_size notes the largest hole noticed _below_
@@ -457,7 +458,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	va->flags = 0;
 	__insert_vmap_area(va);
 	free_vmap_cache = &va->rb_node;
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 
 	BUG_ON(!IS_ALIGNED(va->va_start, align));
 	BUG_ON(va->va_start < vstart);
@@ -466,7 +467,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	return va;
 
 overflow:
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 	if (!purged) {
 		purge_vmap_area_lazy();
 		purged = 1;
@@ -541,9 +542,11 @@ static void __free_vmap_area(struct vmap_area *va)
  */
 static void free_vmap_area(struct vmap_area *va)
 {
-	spin_lock(&vmap_area_lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	__free_vmap_area(va);
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 }
 
 /*
@@ -629,6 +632,7 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	struct vmap_area *va;
 	struct vmap_area *n_va;
 	bool do_free = false;
+	unsigned long flags;
 
 	lockdep_assert_held(&vmap_purge_lock);
 
@@ -646,15 +650,17 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 
 	flush_tlb_kernel_range(start, end);
 
-	spin_lock(&vmap_area_lock);
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
 		int nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
 
 		__free_vmap_area(va);
 		atomic_sub(nr, &vmap_lazy_nr);
-		cond_resched_lock(&vmap_area_lock);
+		spin_unlock_irqrestore(&vmap_area_lock, flags);
+		cond_resched();
+		spin_lock_irqsave(&vmap_area_lock, flags);
 	}
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 	return true;
 }
 
@@ -713,10 +719,11 @@ static void free_unmap_vmap_area(struct vmap_area *va)
 static struct vmap_area *find_vmap_area(unsigned long addr)
 {
 	struct vmap_area *va;
+	unsigned long flags;
 
-	spin_lock(&vmap_area_lock);
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	va = __find_vmap_area(addr);
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 
 	return va;
 }
@@ -1313,14 +1320,16 @@ EXPORT_SYMBOL_GPL(map_vm_area);
 static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 			      unsigned long flags, const void *caller)
 {
-	spin_lock(&vmap_area_lock);
+	unsigned long irq_flags;
+
+	spin_lock_irqsave(&vmap_area_lock, irq_flags);
 	vm->flags = flags;
 	vm->addr = (void *)va->va_start;
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
 	va->vm = vm;
 	va->flags |= VM_VM_AREA;
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, irq_flags);
 }
 
 static void clear_vm_uninitialized_flag(struct vm_struct *vm)
@@ -1443,11 +1452,12 @@ struct vm_struct *remove_vm_area(const void *addr)
 	va = find_vmap_area((unsigned long)addr);
 	if (va && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->vm;
+		unsigned long flags;
 
-		spin_lock(&vmap_area_lock);
+		spin_lock_irqsave(&vmap_area_lock, flags);
 		va->vm = NULL;
 		va->flags &= ~VM_VM_AREA;
-		spin_unlock(&vmap_area_lock);
+		spin_unlock_irqrestore(&vmap_area_lock, flags);
 
 		vmap_debug_free_range(va->va_start, va->va_end);
 		kasan_free_shadow(vm);
@@ -1858,6 +1868,11 @@ void *vzalloc_node(unsigned long size, int node)
 }
 EXPORT_SYMBOL(vzalloc_node);
 
+void *vmalloc_gfp(unsigned long size, gfp_t gfp_mask)
+{
+	return __vmalloc_node_flags(size, NUMA_NO_NODE, gfp_mask);
+}
+
 #ifndef PAGE_KERNEL_EXEC
 # define PAGE_KERNEL_EXEC PAGE_KERNEL
 #endif
@@ -2038,12 +2053,13 @@ long vread(char *buf, char *addr, unsigned long count)
 	char *vaddr, *buf_start = buf;
 	unsigned long buflen = count;
 	unsigned long n;
+	unsigned long flags;
 
 	/* Don't allow overflow */
 	if ((unsigned long) addr + count < count)
 		count = -(unsigned long) addr;
 
-	spin_lock(&vmap_area_lock);
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	list_for_each_entry(va, &vmap_area_list, list) {
 		if (!count)
 			break;
@@ -2075,7 +2091,7 @@ long vread(char *buf, char *addr, unsigned long count)
 		count -= n;
 	}
 finished:
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 
 	if (buf == buf_start)
 		return 0;
@@ -2119,13 +2135,14 @@ long vwrite(char *buf, char *addr, unsigned long count)
 	char *vaddr;
 	unsigned long n, buflen;
 	int copied = 0;
+	unsigned long flags;
 
 	/* Don't allow overflow */
 	if ((unsigned long) addr + count < count)
 		count = -(unsigned long) addr;
 	buflen = count;
 
-	spin_lock(&vmap_area_lock);
+	spin_lock_irqsave(&vmap_area_lock, flags);
 	list_for_each_entry(va, &vmap_area_list, list) {
 		if (!count)
 			break;
@@ -2156,7 +2173,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		count -= n;
 	}
 finished:
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 	if (!copied)
 		return 0;
 	return buflen;
@@ -2416,7 +2433,7 @@ static unsigned long pvm_determine_end(struct vmap_area **pnext,
  */
 struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 				     const size_t *sizes, int nr_vms,
-				     size_t align)
+				     size_t align, gfp_t gfp_mask)
 {
 	const unsigned long vmalloc_start = ALIGN(VMALLOC_START, align);
 	const unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
@@ -2425,6 +2442,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 	int area, area2, last_area, term_area;
 	unsigned long base, start, end, last_end;
 	bool purged = false;
+	unsigned long flags;
 
 	/* verify parameters and allocate data structures */
 	BUG_ON(offset_in_page(align) || !is_power_of_2(align));
@@ -2458,19 +2476,19 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		return NULL;
 	}
 
-	vms = kcalloc(nr_vms, sizeof(vms[0]), GFP_KERNEL);
-	vas = kcalloc(nr_vms, sizeof(vas[0]), GFP_KERNEL);
+	vms = kcalloc(nr_vms, sizeof(vms[0]), gfp_mask);
+	vas = kcalloc(nr_vms, sizeof(vas[0]), gfp_mask);
 	if (!vas || !vms)
 		goto err_free2;
 
 	for (area = 0; area < nr_vms; area++) {
-		vas[area] = kzalloc(sizeof(struct vmap_area), GFP_KERNEL);
-		vms[area] = kzalloc(sizeof(struct vm_struct), GFP_KERNEL);
+		vas[area] = kzalloc(sizeof(struct vmap_area), gfp_mask);
+		vms[area] = kzalloc(sizeof(struct vm_struct), gfp_mask);
 		if (!vas[area] || !vms[area])
 			goto err_free;
 	}
 retry:
-	spin_lock(&vmap_area_lock);
+	spin_lock_irqsave(&vmap_area_lock, flags);
 
 	/* start scanning - we scan from the top, begin with the last area */
 	area = term_area = last_area;
@@ -2492,7 +2510,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		 * comparing.
 		 */
 		if (base + last_end < vmalloc_start + last_end) {
-			spin_unlock(&vmap_area_lock);
+			spin_unlock_irqrestore(&vmap_area_lock, flags);
 			if (!purged) {
 				purge_vmap_area_lazy();
 				purged = true;
@@ -2547,7 +2565,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 
 	vmap_area_pcpu_hole = base + offsets[last_area];
 
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irqrestore(&vmap_area_lock, flags);
 
 	/* insert all vm's */
 	for (area = 0; area < nr_vms; area++)
@@ -2589,7 +2607,7 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
 static void *s_start(struct seq_file *m, loff_t *pos)
 	__acquires(&vmap_area_lock)
 {
-	spin_lock(&vmap_area_lock);
+	spin_lock_irq(&vmap_area_lock);
 	return seq_list_start(&vmap_area_list, *pos);
 }
 
@@ -2601,7 +2619,7 @@ static void *s_next(struct seq_file *m, void *p, loff_t *pos)
 static void s_stop(struct seq_file *m, void *p)
 	__releases(&vmap_area_lock)
 {
-	spin_unlock(&vmap_area_lock);
+	spin_unlock_irq(&vmap_area_lock);
 }
 
 static void show_numa_info(struct seq_file *m, struct vm_struct *v)
-- 
2.11.0.483.g087da7b7c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
