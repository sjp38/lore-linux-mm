Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 903646B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 19:58:13 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fl4so41218559pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 16:58:13 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id sf6si15843731pac.76.2016.02.25.16.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 16:58:12 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id q63so42021385pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 16:58:11 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v4 1/2] mm: introduce page reference manipulation functions
Date: Fri, 26 Feb 2016 09:58:01 +0900
Message-Id: <1456448282-897-1-git-send-email-iamjoonsoo.kim@lge.com>
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

In addition, this patch also converts reference read sites. It will help
a second step that renames page._count to something else and prevents later
attempt to direct access to it (Suggested by Andrew).

Acked-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/mips/mm/gup.c                                |  2 +-
 arch/powerpc/mm/mmu_context_hash64.c              |  3 +-
 arch/powerpc/mm/pgtable_64.c                      |  2 +-
 arch/powerpc/platforms/512x/mpc512x_shared.c      |  2 +-
 arch/x86/mm/gup.c                                 |  2 +-
 drivers/block/aoe/aoecmd.c                        |  4 +-
 drivers/net/ethernet/freescale/gianfar.c          |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c     |  2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |  9 ++-
 drivers/net/ethernet/qlogic/qede/qede_main.c      |  2 +-
 drivers/net/ethernet/sun/niu.c                    |  2 +-
 fs/nilfs2/page.c                                  |  2 +-
 include/linux/mm.h                                | 25 ++-----
 include/linux/page_ref.h                          | 85 +++++++++++++++++++++++
 include/linux/pagemap.h                           | 19 +----
 mm/debug.c                                        |  2 +-
 mm/huge_memory.c                                  |  6 +-
 mm/internal.h                                     |  7 +-
 mm/memory_hotplug.c                               |  4 +-
 mm/migrate.c                                      | 10 +--
 mm/page_alloc.c                                   | 12 ++--
 mm/vmscan.c                                       |  6 +-
 net/core/sock.c                                   |  2 +-
 26 files changed, 135 insertions(+), 83 deletions(-)
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
diff --git a/arch/powerpc/platforms/512x/mpc512x_shared.c b/arch/powerpc/platforms/512x/mpc512x_shared.c
index 711f3d3..452da23 100644
--- a/arch/powerpc/platforms/512x/mpc512x_shared.c
+++ b/arch/powerpc/platforms/512x/mpc512x_shared.c
@@ -188,7 +188,7 @@ static struct fsl_diu_shared_fb __attribute__ ((__aligned__(8))) diu_shared_fb;
 static inline void mpc512x_free_bootmem(struct page *page)
 {
 	BUG_ON(PageTail(page));
-	BUG_ON(atomic_read(&page->_count) > 1);
+	BUG_ON(page_ref_count(page) > 1);
 	free_reserved_page(page);
 }
 
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
index 41440b2..86bcfe5 100644
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
@@ -165,7 +164,7 @@ static int mlx4_en_init_allocator(struct mlx4_en_priv *priv,
 
 		en_dbg(DRV, priv, "  frag %d allocator: - size:%d frags:%d\n",
 		       i, ring->page_alloc[i].page_size,
-		       atomic_read(&ring->page_alloc[i].page->_count));
+		       page_ref_count(ring->page_alloc[i].page));
 	}
 	return 0;
 
@@ -177,7 +176,7 @@ out:
 		dma_unmap_page(priv->ddev, page_alloc->dma,
 			       page_alloc->page_size, PCI_DMA_FROMDEVICE);
 		page = page_alloc->page;
-		atomic_set(&page->_count, 1);
+		set_page_count(page, 1);
 		put_page(page);
 		page_alloc->page = NULL;
 	}
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 5f15e23..a375d2e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -763,7 +763,7 @@ static inline int qede_realloc_rx_buffer(struct qede_dev *edev,
 		 * network stack to take the ownership of the page
 		 * which can be recycled multiple times by the driver.
 		 */
-		atomic_inc(&curr_cons->data->_count);
+		page_ref_inc(curr_cons->data);
 		qede_reuse_page(edev, rxq, curr_cons);
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
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 45d650a..c20df77 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -180,7 +180,7 @@ void nilfs_page_bug(struct page *page)
 
 	printk(KERN_CRIT "NILFS_PAGE_BUG(%p): cnt=%d index#=%llu flags=0x%lx "
 	       "mapping=%p ino=%lu\n",
-	       page, atomic_read(&page->_count),
+	       page, page_ref_count(page),
 	       (unsigned long long)page->index, page->flags, m, ino);
 
 	if (page_has_buffers(page)) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fe4d988..3ef0bfb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -22,6 +22,7 @@
 #include <linux/resource.h>
 #include <linux/page_ext.h>
 #include <linux/err.h>
+#include <linux/page_ref.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -386,8 +387,8 @@ static inline int pmd_devmap(pmd_t pmd)
  */
 static inline int put_page_testzero(struct page *page)
 {
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) == 0, page);
-	return atomic_dec_and_test(&page->_count);
+	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
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
@@ -716,8 +703,8 @@ static inline void get_page(struct page *page)
 	 * Getting a normal page or the head of a compound page
 	 * requires to already have an elevated page->_count.
 	 */
-	VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
-	atomic_inc(&page->_count);
+	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
+	page_ref_inc(page);
 
 	if (unlikely(is_zone_device_page(page)))
 		get_zone_device_page(page);
diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
new file mode 100644
index 0000000..30f5817
--- /dev/null
+++ b/include/linux/page_ref.h
@@ -0,0 +1,85 @@
+#ifndef _LINUX_PAGE_REF_H
+#define _LINUX_PAGE_REF_H
+
+#include <linux/atomic.h>
+#include <linux/mm_types.h>
+#include <linux/page-flags.h>
+
+static inline int page_ref_count(struct page *page)
+{
+	return atomic_read(&page->_count);
+}
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
+#endif
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
diff --git a/mm/debug.c b/mm/debug.c
index df7247b..8865bfb 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -43,7 +43,7 @@ const struct trace_print_flags vmaflag_names[] = {
 void __dump_page(struct page *page, const char *reason)
 {
 	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
-		  page, atomic_read(&page->_count), page_mapcount(page),
+		  page, page_ref_count(page), page_mapcount(page),
 		  page->mapping, page->index);
 	if (PageCompound(page))
 		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 83dc952..92b6508 100644
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
@@ -3301,7 +3301,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	struct page *page_tail = head + tail;
 
 	VM_BUG_ON_PAGE(atomic_read(&page_tail->_mapcount) != -1, page_tail);
-	VM_BUG_ON_PAGE(atomic_read(&page_tail->_count) != 0, page_tail);
+	VM_BUG_ON_PAGE(page_ref_count(page_tail) != 0, page_tail);
 
 	/*
 	 * tail_page->_count is zero and not changing from under us. But
@@ -3314,7 +3314,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 	 * atomic_set() here would be safe on all archs (and not only on x86),
 	 * it's safer to use atomic_inc().
 	 */
-	atomic_inc(&page_tail->_count);
+	page_ref_inc(page_tail);
 
 	page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	page_tail->flags |= (head->flags &
diff --git a/mm/internal.h b/mm/internal.h
index f9153e5..f4522962 100644
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
@@ -73,7 +68,7 @@ static inline unsigned long ra_submit(struct file_ra_state *ra,
 static inline void set_page_refcounted(struct page *page)
 {
 	VM_BUG_ON_PAGE(PageTail(page), page);
-	VM_BUG_ON_PAGE(atomic_read(&page->_count), page);
+	VM_BUG_ON_PAGE(page_ref_count(page), page);
 	set_page_count(page, 1);
 }
 
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
index 85e7588..0fb23d1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -765,7 +765,7 @@ static inline int free_pages_check(struct page *page)
 		bad_reason = "nonzero mapcount";
 	if (unlikely(page->mapping != NULL))
 		bad_reason = "non-NULL mapping";
-	if (unlikely(atomic_read(&page->_count) != 0))
+	if (unlikely(page_ref_count(page) != 0))
 		bad_reason = "nonzero _count";
 	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_FREE)) {
 		bad_reason = "PAGE_FLAGS_CHECK_AT_FREE flag(s) set";
@@ -1461,7 +1461,7 @@ static inline int check_new_page(struct page *page)
 		bad_reason = "nonzero mapcount";
 	if (unlikely(page->mapping != NULL))
 		bad_reason = "non-NULL mapping";
-	if (unlikely(atomic_read(&page->_count) != 0))
+	if (unlikely(page_ref_count(page) != 0))
 		bad_reason = "nonzero _count";
 	if (unlikely(page->flags & __PG_HWPOISON)) {
 		bad_reason = "HWPoisoned (hardware-corrupted)";
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
@@ -6940,7 +6940,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * This check already skips compound tails of THP
 		 * because their page->_count is zero at all time.
 		 */
-		if (!atomic_read(&page->_count)) {
+		if (!page_ref_count(page)) {
 			if (PageBuddy(page))
 				iter += (1 << page_order(page)) - 1;
 			continue;
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
diff --git a/net/core/sock.c b/net/core/sock.c
index 46dc8ad..3ee03b8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1904,7 +1904,7 @@ EXPORT_SYMBOL(sock_cmsg_send);
 bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t gfp)
 {
 	if (pfrag->page) {
-		if (atomic_read(&pfrag->page->_count) == 1) {
+		if (page_ref_count(pfrag->page) == 1) {
 			pfrag->offset = 0;
 			return true;
 		}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
