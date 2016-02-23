Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3921B82F69
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 02:21:31 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id q63so107378206pfb.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 23:21:31 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id tm2si45370612pac.109.2016.02.22.23.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 23:21:29 -0800 (PST)
Received: by mail-pa0-x233.google.com with SMTP id yy13so105558552pab.3
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 23:21:29 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v3 1/2] mm: introduce page reference manipulation functions
Date: Tue, 23 Feb 2016 16:21:17 +0900
Message-Id: <1456212078-22732-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Success of CMA allocation largely depends on success of migration
and key factor of it is page reference count. Until now, page reference
is manipulated by direct calling atomic functions so we cannot follow up
who and where manipulate it. Then, it is hard to find actual reason
of CMA allocation failure. CMA allocation should be guaranteed to succeed
so finding offending place is really important.

In this patch, call sites where page reference is manipulated are converted
to introduced wrapper function. This is preparation step to add tracepoint
to each page reference manipulation function. With this facility, we can
easily find reason of CMA allocation failure. There is no functional change
in this patch.

Acked-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/mips/mm/gup.c                                |  2 +-
 arch/powerpc/mm/mmu_context_hash64.c              |  3 +-
 arch/powerpc/mm/pgtable_64.c                      |  2 +-
 arch/x86/mm/gup.c                                 |  2 +-
 drivers/block/aoe/aoecmd.c                        |  4 +-
 drivers/net/ethernet/freescale/gianfar.c          |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |  2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |  7 +--
 drivers/net/ethernet/sun/niu.c                    |  2 +-
 include/linux/mm.h                                | 21 ++-----
 include/linux/page_ref.h                          | 76 +++++++++++++++++++++++
 include/linux/pagemap.h                           | 19 +-----
 mm/huge_memory.c                                  |  4 +-
 mm/internal.h                                     |  5 --
 mm/memory_hotplug.c                               |  4 +-
 mm/migrate.c                                      | 10 +--
 mm/page_alloc.c                                   |  6 +-
 mm/vmscan.c                                       |  6 +-
 21 files changed, 113 insertions(+), 70 deletions(-)
 create mode 100644 include/linux/page_ref.h

diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 1afd87c..6cdffc7 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -64,7 +64,7 @@ static inline void get_head_page_multiple(struct page *page, int nr)
 {
 	VM_BUG_ON(page != compound_head(page));
 	VM_BUG_ON(page_count(page) == 0);
-	atomic_add(nr, &page->_count);
+	page_ref_add(page, nr);
 	SetPageReferenced(page);
 }
 
diff --git a/arch/powerpc/mm/mmu_context_hash64.c b/arch/powerpc/mm/mmu_context_hash64.c
index 4e4efbc..9ca6fe1 100644
--- a/arch/powerpc/mm/mmu_context_hash64.c
+++ b/arch/powerpc/mm/mmu_context_hash64.c
@@ -118,8 +118,7 @@ static void destroy_pagetable_page(struct mm_struct *mm)
 	/* drop all the pending references */
 	count = ((unsigned long)pte_frag & ~PAGE_MASK) >> PTE_FRAG_SIZE_SHIFT;
 	/* We allow PTE_FRAG_NR fragments from a PTE page */
-	count = atomic_sub_return(PTE_FRAG_NR - count, &page->_count);
-	if (!count) {
+	if (page_ref_sub_and_test(page, PTE_FRAG_NR - count)) {
 		pgtable_page_dtor(page);
 		free_hot_cold_page(page, 0);
 	}
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index cdf2123..d9cc66c 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -403,7 +403,7 @@ static pte_t *__alloc_for_cache(struct mm_struct *mm, int kernel)
 	 * count.
 	 */
 	if (likely(!mm->context.pte_frag)) {
-		atomic_set(&page->_count, PTE_FRAG_NR);
+		set_page_count(page, PTE_FRAG_NR);
 		mm->context.pte_frag = ret + PTE_FRAG_SIZE;
 	}
 	spin_unlock(&mm->page_table_lock);
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index d8a798d..f8d0b5e 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -131,7 +131,7 @@ static inline void get_head_page_multiple(struct page *page, int nr)
 {
 	VM_BUG_ON_PAGE(page != compound_head(page), page);
 	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	atomic_add(nr, &page->_count);
+	page_ref_add(page, nr);
 	SetPageReferenced(page);
 }
 
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index d048d20..437b3a8 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -875,7 +875,7 @@ bio_pageinc(struct bio *bio)
 		 * compound pages is no longer allowed by the kernel.
 		 */
 		page = compound_head(bv.bv_page);
-		atomic_inc(&page->_count);
+		page_ref_inc(page);
 	}
 }
 
@@ -888,7 +888,7 @@ bio_pagedec(struct bio *bio)
 
 	bio_for_each_segment(bv, bio, iter) {
 		page = compound_head(bv.bv_page);
-		atomic_dec(&page->_count);
+		page_ref_dec(page);
 	}
 }
 
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2aa7b40..3b8d45a 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2942,7 +2942,7 @@ static bool gfar_add_rx_frag(struct gfar_rx_buff *rxb, u32 lstatus,
 	/* change offset to the other half */
 	rxb->page_offset ^= GFAR_RXB_TRUESIZE;
 
-	atomic_inc(&page->_count);
+	page_ref_inc(page);
 
 	return true;
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 38f558e..4de17db 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -243,7 +243,7 @@ static bool fm10k_can_reuse_rx_page(struct fm10k_rx_buffer *rx_buffer,
 	/* Even if we own the page, we are not allowed to use atomic_set()
 	 * This would break get_page_unless_zero() users.
 	 */
-	atomic_inc(&page->_count);
+	page_ref_inc(page);
 
 	return true;
 }
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index af46fcf..2659f66 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6722,7 +6722,7 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
 	/* Even if we own the page, we are not allowed to use atomic_set()
 	 * This would break get_page_unless_zero() users.
 	 */
-	atomic_inc(&page->_count);
+	page_ref_inc(page);
 
 	return true;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cf4b729..3387e62 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1945,7 +1945,7 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 	/* Even if we own the page, we are not allowed to use atomic_set()
 	 * This would break get_page_unless_zero() users.
 	 */
-	atomic_inc(&page->_count);
+	page_ref_inc(page);
 
 	return true;
 }
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 3558f01..0ea14c0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -837,7 +837,7 @@ add_tail_frag:
 	/* Even if we own the page, we are not allowed to use atomic_set()
 	 * This would break get_page_unless_zero() users.
 	 */
-	atomic_inc(&page->_count);
+	page_ref_inc(page);
 
 	return true;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 41440b2..04758f1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -82,8 +82,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 	/* Not doing get_page() for each frag is a big win
 	 * on asymetric workloads. Note we can not use atomic_set().
 	 */
-	atomic_add(page_alloc->page_size / frag_info->frag_stride - 1,
-		   &page->_count);
+	page_ref_add(page, page_alloc->page_size / frag_info->frag_stride - 1);
 	return 0;
 }
 
@@ -127,7 +126,7 @@ out:
 			dma_unmap_page(priv->ddev, page_alloc[i].dma,
 				page_alloc[i].page_size, PCI_DMA_FROMDEVICE);
 			page = page_alloc[i].page;
-			atomic_set(&page->_count, 1);
+			set_page_count(page, 1);
 			put_page(page);
 		}
 	}
@@ -177,7 +176,7 @@ out:
 		dma_unmap_page(priv->ddev, page_alloc->dma,
 			       page_alloc->page_size, PCI_DMA_FROMDEVICE);
 		page = page_alloc->page;
-		atomic_set(&page->_count, 1);
+		set_page_count(page, 1);
 		put_page(page);
 		page_alloc->page = NULL;
 	}
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index ab6051a..9cc4564 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3341,7 +3341,7 @@ static int niu_rbr_add_page(struct niu *np, struct rx_ring_info *rp,
 
 	niu_hash_page(rp, page, addr);
 	if (rp->rbr_blocks_per_page > 1)
-		atomic_add(rp->rbr_blocks_per_page - 1, &page->_count);
+		page_ref_add(page, rp->rbr_blocks_per_page - 1);
 
 	for (i = 0; i < rp->rbr_blocks_per_page; i++) {
 		__le32 *rbr = &rp->rbr[start_index + i];
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fe4d988..4494416 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -22,6 +22,7 @@
 #include <linux/resource.h>
 #include <linux/page_ext.h>
 #include <linux/err.h>
+#include <linux/page_ref.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -387,7 +388,7 @@ static inline int pmd_devmap(pmd_t pmd)
 static inline int put_page_testzero(struct page *page)
 {
 	VM_BUG_ON_PAGE(atomic_read(&page->_count) == 0, page);
-	return atomic_dec_and_test(&page->_count);
+	return page_ref_dec_and_test(page);
 }
 
 /*
@@ -398,7 +399,7 @@ static inline int put_page_testzero(struct page *page)
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	return atomic_inc_not_zero(&page->_count);
+	return page_ref_add_unless(page, 1, 0);
 }
 
 extern int page_is_ram(unsigned long pfn);
@@ -486,11 +487,6 @@ static inline int total_mapcount(struct page *page)
 }
 #endif
 
-static inline int page_count(struct page *page)
-{
-	return atomic_read(&compound_head(page)->_count);
-}
-
 static inline struct page *virt_to_head_page(const void *x)
 {
 	struct page *page = virt_to_page(x);
@@ -498,15 +494,6 @@ static inline struct page *virt_to_head_page(const void *x)
 	return compound_head(page);
 }
 
-/*
- * Setup the page count before being freed into the page allocator for
- * the first time (boot or memory hotplug)
- */
-static inline void init_page_count(struct page *page)
-{
-	atomic_set(&page->_count, 1);
-}
-
 void __put_page(struct page *page);
 
 void put_pages_list(struct list_head *pages);
@@ -717,7 +704,7 @@ static inline void get_page(struct page *page)
 	 * requires to already have an elevated page->_count.
 	 */
 	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
-	atomic_inc(&page->_count);
+	page_ref_inc(page);
 
 	if (unlikely(is_zone_device_page(page)))
 		get_zone_device_page(page);
diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
new file mode 100644
index 0000000..534249c
--- /dev/null
+++ b/include/linux/page_ref.h
@@ -0,0 +1,76 @@
+#include <linux/atomic.h>
+#include <linux/mm_types.h>
+#include <linux/page-flags.h>
+
+static inline int page_count(struct page *page)
+{
+	return atomic_read(&compound_head(page)->_count);
+}
+
+static inline void set_page_count(struct page *page, int v)
+{
+	atomic_set(&page->_count, v);
+}
+
+/*
+ * Setup the page count before being freed into the page allocator for
+ * the first time (boot or memory hotplug)
+ */
+static inline void init_page_count(struct page *page)
+{
+	set_page_count(page, 1);
+}
+
+static inline void page_ref_add(struct page *page, int nr)
+{
+	atomic_add(nr, &page->_count);
+}
+
+static inline void page_ref_sub(struct page *page, int nr)
+{
+	atomic_sub(nr, &page->_count);
+}
+
+static inline void page_ref_inc(struct page *page)
+{
+	atomic_inc(&page->_count);
+}
+
+static inline void page_ref_dec(struct page *page)
+{
+	atomic_dec(&page->_count);
+}
+
+static inline int page_ref_sub_and_test(struct page *page, int nr)
+{
+	return atomic_sub_and_test(nr, &page->_count);
+}
+
+static inline int page_ref_dec_and_test(struct page *page)
+{
+	return atomic_dec_and_test(&page->_count);
+}
+
+static inline int page_ref_dec_return(struct page *page)
+{
+	return atomic_dec_return(&page->_count);
+}
+
+static inline int page_ref_add_unless(struct page *page, int nr, int u)
+{
+	return atomic_add_unless(&page->_count, nr, u);
+}
+
+static inline int page_ref_freeze(struct page *page, int count)
+{
+	return likely(atomic_cmpxchg(&page->_count, count, 0) == count);
+}
+
+static inline void page_ref_unfreeze(struct page *page, int count)
+{
+	VM_BUG_ON_PAGE(page_count(page) != 0, page);
+	VM_BUG_ON(count == 0);
+
+	atomic_set(&page->_count, count);
+}
+
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 183b15e..1ebd65c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -165,7 +165,7 @@ static inline int page_cache_get_speculative(struct page *page)
 	 * SMP requires.
 	 */
 	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	atomic_inc(&page->_count);
+	page_ref_inc(page);
 
 #else
 	if (unlikely(!get_page_unless_zero(page))) {
@@ -194,10 +194,10 @@ static inline int page_cache_add_speculative(struct page *page, int count)
 	VM_BUG_ON(!in_atomic());
 # endif
 	VM_BUG_ON_PAGE(page_count(page) == 0, page);
-	atomic_add(count, &page->_count);
+	page_ref_add(page, count);
 
 #else
-	if (unlikely(!atomic_add_unless(&page->_count, count, 0)))
+	if (unlikely(!page_ref_add_unless(page, count, 0)))
 		return 0;
 #endif
 	VM_BUG_ON_PAGE(PageCompound(page) && page != compound_head(page), page);
@@ -205,19 +205,6 @@ static inline int page_cache_add_speculative(struct page *page, int count)
 	return 1;
 }
 
-static inline int page_freeze_refs(struct page *page, int count)
-{
-	return likely(atomic_cmpxchg(&page->_count, count, 0) == count);
-}
-
-static inline void page_unfreeze_refs(struct page *page, int count)
-{
-	VM_BUG_ON_PAGE(page_count(page) != 0, page);
-	VM_BUG_ON(count == 0);
-
-	atomic_set(&page->_count, count);
-}
-
 #ifdef CONFIG_NUMA
 extern struct page *__page_cache_alloc(gfp_t gfp);
 #else
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 83dc952..46ad357 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2932,7 +2932,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	page = pmd_page(*pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
-	atomic_add(HPAGE_PMD_NR - 1, &page->_count);
+	page_ref_add(page, HPAGE_PMD_NR - 1);
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
 	dirty = pmd_dirty(*pmd);
@@ -3314,7 +3314,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	 * atomic_set() here would be safe on all archs (and not only on x86),
 	 * it's safer to use atomic_inc().
 	 */
-	atomic_inc(&page_tail->_count);
+	page_ref_inc(page_tail);
 
 	page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	page_tail->flags |= (head->flags &
diff --git a/mm/internal.h b/mm/internal.h
index f9153e5..72bbce3 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -47,11 +47,6 @@ void unmap_page_range(struct mmu_gather *tlb,
 			     unsigned long addr, unsigned long end,
 			     struct zap_details *details);
 
-static inline void set_page_count(struct page *page, int v)
-{
-	atomic_set(&page->_count, v);
-}
-
 extern int __do_page_cache_readahead(struct address_space *mapping,
 		struct file *filp, pgoff_t offset, unsigned long nr_to_read,
 		unsigned long lookahead_size);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c832ef3..e62aa07 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -167,7 +167,7 @@ void get_page_bootmem(unsigned long info,  struct page *page,
 	page->lru.next = (struct list_head *) type;
 	SetPagePrivate(page);
 	set_page_private(page, info);
-	atomic_inc(&page->_count);
+	page_ref_inc(page);
 }
 
 void put_page_bootmem(struct page *page)
@@ -178,7 +178,7 @@ void put_page_bootmem(struct page *page)
 	BUG_ON(type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
 	       type > MEMORY_HOTPLUG_MAX_BOOTMEM_TYPE);
 
-	if (atomic_dec_return(&page->_count) == 1) {
+	if (page_ref_dec_return(page) == 1) {
 		ClearPagePrivate(page);
 		set_page_private(page, 0);
 		INIT_LIST_HEAD(&page->lru);
diff --git a/mm/migrate.c b/mm/migrate.c
index afaa195..4be6ffe 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -349,7 +349,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 		return -EAGAIN;
 	}
 
-	if (!page_freeze_refs(page, expected_count)) {
+	if (!page_ref_freeze(page, expected_count)) {
 		spin_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
@@ -363,7 +363,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 */
 	if (mode == MIGRATE_ASYNC && head &&
 			!buffer_migrate_lock_buffers(head, mode)) {
-		page_unfreeze_refs(page, expected_count);
+		page_ref_unfreeze(page, expected_count);
 		spin_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
@@ -397,7 +397,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * to one less reference.
 	 * We know this isn't the last reference.
 	 */
-	page_unfreeze_refs(page, expected_count - 1);
+	page_ref_unfreeze(page, expected_count - 1);
 
 	spin_unlock(&mapping->tree_lock);
 	/* Leave irq disabled to prevent preemption while updating stats */
@@ -451,7 +451,7 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
 		return -EAGAIN;
 	}
 
-	if (!page_freeze_refs(page, expected_count)) {
+	if (!page_ref_freeze(page, expected_count)) {
 		spin_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
@@ -463,7 +463,7 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 	radix_tree_replace_slot(pslot, newpage);
 
-	page_unfreeze_refs(page, expected_count - 1);
+	page_ref_unfreeze(page, expected_count - 1);
 
 	spin_unlock_irq(&mapping->tree_lock);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 85e7588..032de4b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3587,7 +3587,7 @@ refill:
 		/* Even if we own the page, we do not use atomic_set().
 		 * This would break get_page_unless_zero() users.
 		 */
-		atomic_add(size - 1, &page->_count);
+		page_ref_add(page, size - 1);
 
 		/* reset page count bias and offset to start of new frag */
 		nc->pfmemalloc = page_is_pfmemalloc(page);
@@ -3599,7 +3599,7 @@ refill:
 	if (unlikely(offset < 0)) {
 		page = virt_to_page(nc->va);
 
-		if (!atomic_sub_and_test(nc->pagecnt_bias, &page->_count))
+		if (!page_ref_sub_and_test(page, nc->pagecnt_bias))
 			goto refill;
 
 #if (PAGE_SIZE < PAGE_FRAG_CACHE_MAX_SIZE)
@@ -3607,7 +3607,7 @@ refill:
 		size = nc->size;
 #endif
 		/* OK, page count is 0, we can safely set it */
-		atomic_set(&page->_count, size);
+		set_page_count(page, size);
 
 		/* reset page count bias and offset to start of new frag */
 		nc->pagecnt_bias = size;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 86eb214..39e90e2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -638,11 +638,11 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	 * Note that if SetPageDirty is always performed via set_page_dirty,
 	 * and thus under tree_lock, then this ordering is not required.
 	 */
-	if (!page_freeze_refs(page, 2))
+	if (!page_ref_freeze(page, 2))
 		goto cannot_free;
 	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
 	if (unlikely(PageDirty(page))) {
-		page_unfreeze_refs(page, 2);
+		page_ref_unfreeze(page, 2);
 		goto cannot_free;
 	}
 
@@ -704,7 +704,7 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 		 * drops the pagecache ref for us without requiring another
 		 * atomic operation.
 		 */
-		page_unfreeze_refs(page, 1);
+		page_ref_unfreeze(page, 1);
 		return 1;
 	}
 	return 0;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
