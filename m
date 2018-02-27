Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 939476B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 19:44:46 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so6452595pfy.20
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 16:44:46 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r13si6162523pgp.504.2018.02.26.16.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 16:44:44 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [RFC -mm] mm: Fix races between swapoff and flush dcache
Date: Tue, 27 Feb 2018 08:44:02 +0800
Message-Id: <20180227004402.4394-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@intel.com>, Chen Liqin <liqin.linux@gmail.com>, Russell King <linux@armlinux.org.uk>, Yoshinori Sato <ysato@users.sourceforge.jp>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Vineet Gupta <vgupta@synopsys.com>, Ley Foon Tan <lftan@altera.com>, Ralf Baechle <ralf@linux-mips.org>, Andi Kleen <ak@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

>From commit 4b3ef9daa4fc ("mm/swap: split swap cache into 64MB
trunks") on, after swapoff, the address_space associated with the swap
device will be freed.  So page_mapping() users which may touch the
address_space need some kind of mechanism to prevent the address_space
from being freed during accessing.

The dcache flushing functions (flush_dcache_page(), etc) in
architecture specific code may access the address_space of swap device
for anonymous pages in swap cache via page_mapping() function.  But in
some cases there are no mechanisms to prevent the swap device from
being swapoff, for example,

CPU1					CPU2
__get_user_pages()			swapoff()
  flush_dcache_page()
    mapping = page_mapping()
      ...				  exit_swap_address_space()
      ...				    kvfree(spaces)
      mapping_mapped(mapping)

The address space may be accessed after being freed.

But from cachetlb.txt and Russell King, flush_dcache_page() only care
about file cache pages, for anonymous pages, flush_anon_page() should
be used.  The implementation of flush_dcache_page() in all
architectures follows this too.  They will check whether
page_mapping() is NULL and whether mapping_mapped() is true to
determine whether to flush the dcache immediately.  And they will use
interval tree (mapping->i_mmap) to find all user space mappings.
While mapping_mapped() and mapping->i_mmap isn't used by anonymous
pages in swap cache at all.

So, to fix the race between swapoff and flush dcache, __page_mapping()
is add to return the address_space for file cache pages and NULL
otherwise.  All page_mapping() invoking in flush dcache functions are
replaced with __page_mapping().

The patch is only build tested, because I have no machine with
architecture other than x86.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Chen Liqin <liqin.linux@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Chris Zankel <chris@zankel.net>
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Ley Foon Tan <lftan@altera.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Andi Kleen <ak@linux.intel.com>
---
 arch/arc/mm/cache.c           |  2 +-
 arch/arm/mm/copypage-v4mc.c   |  2 +-
 arch/arm/mm/copypage-v6.c     |  2 +-
 arch/arm/mm/copypage-xscale.c |  2 +-
 arch/arm/mm/fault-armv.c      |  2 +-
 arch/arm/mm/flush.c           |  6 +++---
 arch/mips/mm/cache.c          |  2 +-
 arch/nios2/mm/cacheflush.c    |  4 ++--
 arch/parisc/kernel/cache.c    |  4 ++--
 arch/score/mm/cache.c         |  4 ++--
 arch/sh/mm/cache-sh4.c        |  2 +-
 arch/sh/mm/cache-sh7705.c     |  2 +-
 arch/sparc/kernel/smp_64.c    |  8 ++++----
 arch/sparc/mm/init_64.c       |  6 +++---
 arch/sparc/mm/tlb.c           |  2 +-
 arch/unicore32/mm/flush.c     |  2 +-
 arch/unicore32/mm/mmu.c       |  2 +-
 arch/xtensa/mm/cache.c        |  2 +-
 include/linux/mm.h            |  1 +
 mm/util.c                     | 20 ++++++++++++++++++++
 20 files changed, 49 insertions(+), 28 deletions(-)

diff --git a/arch/arc/mm/cache.c b/arch/arc/mm/cache.c
index 2072f3451e9c..0f607d5a85da 100644
--- a/arch/arc/mm/cache.c
+++ b/arch/arc/mm/cache.c
@@ -833,7 +833,7 @@ void flush_dcache_page(struct page *page)
 	}
 
 	/* don't handle anon pages here */
-	mapping = page_mapping(page);
+	mapping = __page_mapping(page);
 	if (!mapping)
 		return;
 
diff --git a/arch/arm/mm/copypage-v4mc.c b/arch/arm/mm/copypage-v4mc.c
index 1267e64133b9..6d9e632ca43b 100644
--- a/arch/arm/mm/copypage-v4mc.c
+++ b/arch/arm/mm/copypage-v4mc.c
@@ -70,7 +70,7 @@ void v4_mc_copy_user_highpage(struct page *to, struct page *from,
 	void *kto = kmap_atomic(to);
 
 	if (!test_and_set_bit(PG_dcache_clean, &from->flags))
-		__flush_dcache_page(page_mapping(from), from);
+		__flush_dcache_page(__page_mapping(from), from);
 
 	raw_spin_lock(&minicache_lock);
 
diff --git a/arch/arm/mm/copypage-v6.c b/arch/arm/mm/copypage-v6.c
index 70423345da26..2f13ffd847a6 100644
--- a/arch/arm/mm/copypage-v6.c
+++ b/arch/arm/mm/copypage-v6.c
@@ -76,7 +76,7 @@ static void v6_copy_user_highpage_aliasing(struct page *to,
 	unsigned long kfrom, kto;
 
 	if (!test_and_set_bit(PG_dcache_clean, &from->flags))
-		__flush_dcache_page(page_mapping(from), from);
+		__flush_dcache_page(__page_mapping(from), from);
 
 	/* FIXME: not highmem safe */
 	discard_old_kernel_data(page_address(to));
diff --git a/arch/arm/mm/copypage-xscale.c b/arch/arm/mm/copypage-xscale.c
index 0fb85025344d..221129649627 100644
--- a/arch/arm/mm/copypage-xscale.c
+++ b/arch/arm/mm/copypage-xscale.c
@@ -90,7 +90,7 @@ void xscale_mc_copy_user_highpage(struct page *to, struct page *from,
 	void *kto = kmap_atomic(to);
 
 	if (!test_and_set_bit(PG_dcache_clean, &from->flags))
-		__flush_dcache_page(page_mapping(from), from);
+		__flush_dcache_page(__page_mapping(from), from);
 
 	raw_spin_lock(&minicache_lock);
 
diff --git a/arch/arm/mm/fault-armv.c b/arch/arm/mm/fault-armv.c
index d9e0d00a6699..593bd1549ce0 100644
--- a/arch/arm/mm/fault-armv.c
+++ b/arch/arm/mm/fault-armv.c
@@ -195,7 +195,7 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long addr,
 	if (page == ZERO_PAGE(0))
 		return;
 
-	mapping = page_mapping(page);
+	mapping = __page_mapping(page);
 	if (!test_and_set_bit(PG_dcache_clean, &page->flags))
 		__flush_dcache_page(mapping, page);
 	if (mapping) {
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index f1e6190aa7ea..2e4a478c6f02 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -285,7 +285,7 @@ void __sync_icache_dcache(pte_t pteval)
 
 	page = pfn_to_page(pfn);
 	if (cache_is_vipt_aliasing())
-		mapping = page_mapping(page);
+		mapping = __page_mapping(page);
 	else
 		mapping = NULL;
 
@@ -333,7 +333,7 @@ void flush_dcache_page(struct page *page)
 		return;
 	}
 
-	mapping = page_mapping(page);
+	mapping = __page_mapping(page);
 
 	if (!cache_ops_need_broadcast() &&
 	    mapping && !page_mapcount(page))
@@ -363,7 +363,7 @@ void flush_kernel_dcache_page(struct page *page)
 	if (cache_is_vivt() || cache_is_vipt_aliasing()) {
 		struct address_space *mapping;
 
-		mapping = page_mapping(page);
+		mapping = __page_mapping(page);
 
 		if (!mapping || mapping_mapped(mapping)) {
 			void *addr;
diff --git a/arch/mips/mm/cache.c b/arch/mips/mm/cache.c
index 44ac64d51827..8a21c0345516 100644
--- a/arch/mips/mm/cache.c
+++ b/arch/mips/mm/cache.c
@@ -86,7 +86,7 @@ SYSCALL_DEFINE3(cacheflush, unsigned long, addr, unsigned long, bytes,
 
 void __flush_dcache_page(struct page *page)
 {
-	struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping = __page_mapping(page);
 	unsigned long addr;
 
 	if (mapping && !mapping_mapped(mapping)) {
diff --git a/arch/nios2/mm/cacheflush.c b/arch/nios2/mm/cacheflush.c
index 87bf88ed04c6..117bece3eb80 100644
--- a/arch/nios2/mm/cacheflush.c
+++ b/arch/nios2/mm/cacheflush.c
@@ -180,7 +180,7 @@ void flush_dcache_page(struct page *page)
 	if (page == ZERO_PAGE(0))
 		return;
 
-	mapping = page_mapping(page);
+	mapping = __page_mapping(page);
 
 	/* Flush this page if there are aliases. */
 	if (mapping && !mapping_mapped(mapping)) {
@@ -215,7 +215,7 @@ void update_mmu_cache(struct vm_area_struct *vma,
 	if (page == ZERO_PAGE(0))
 		return;
 
-	mapping = page_mapping(page);
+	mapping = __page_mapping(page);
 	if (!test_and_set_bit(PG_dcache_clean, &page->flags))
 		__flush_dcache_page(mapping, page);
 
diff --git a/arch/parisc/kernel/cache.c b/arch/parisc/kernel/cache.c
index 7c1bde80ada4..2150dd193654 100644
--- a/arch/parisc/kernel/cache.c
+++ b/arch/parisc/kernel/cache.c
@@ -88,7 +88,7 @@ update_mmu_cache(struct vm_area_struct *vma, unsigned long address, pte_t *ptep)
 		return;
 
 	page = pfn_to_page(pfn);
-	if (page_mapping(page) && test_bit(PG_dcache_dirty, &page->flags)) {
+	if (__page_mapping(page) && test_bit(PG_dcache_dirty, &page->flags)) {
 		flush_kernel_dcache_page_addr(pfn_va(pfn));
 		clear_bit(PG_dcache_dirty, &page->flags);
 	} else if (parisc_requires_coherency())
@@ -304,7 +304,7 @@ __flush_cache_page(struct vm_area_struct *vma, unsigned long vmaddr,
 
 void flush_dcache_page(struct page *page)
 {
-	struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping = __page_mapping(page);
 	struct vm_area_struct *mpnt;
 	unsigned long offset;
 	unsigned long addr, old_addr = 0;
diff --git a/arch/score/mm/cache.c b/arch/score/mm/cache.c
index b4bcfd3e8393..a74967a396e6 100644
--- a/arch/score/mm/cache.c
+++ b/arch/score/mm/cache.c
@@ -54,7 +54,7 @@ static void flush_data_cache_page(unsigned long addr)
 
 void flush_dcache_page(struct page *page)
 {
-	struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping = __page_mapping(page);
 	unsigned long addr;
 
 	if (PageHighMem(page))
@@ -86,7 +86,7 @@ void __update_cache(struct vm_area_struct *vma, unsigned long address,
 	if (unlikely(!pfn_valid(pfn)))
 		return;
 	page = pfn_to_page(pfn);
-	if (page_mapping(page) && test_bit(PG_dcache_dirty, &(page)->flags)) {
+	if (__page_mapping(page) && test_bit(PG_dcache_dirty, &(page)->flags)) {
 		addr = (unsigned long) page_address(page);
 		if (exec)
 			flush_data_cache_page(addr);
diff --git a/arch/sh/mm/cache-sh4.c b/arch/sh/mm/cache-sh4.c
index 58aaa4f33b81..281e33daaa98 100644
--- a/arch/sh/mm/cache-sh4.c
+++ b/arch/sh/mm/cache-sh4.c
@@ -112,7 +112,7 @@ static void sh4_flush_dcache_page(void *arg)
 	struct page *page = arg;
 	unsigned long addr = (unsigned long)page_address(page);
 #ifndef CONFIG_SMP
-	struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping = __page_mapping(page);
 
 	if (mapping && !mapping_mapped(mapping))
 		clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/sh/mm/cache-sh7705.c b/arch/sh/mm/cache-sh7705.c
index 6cd2aa395817..92db57ccc35a 100644
--- a/arch/sh/mm/cache-sh7705.c
+++ b/arch/sh/mm/cache-sh7705.c
@@ -136,7 +136,7 @@ static void __flush_dcache_page(unsigned long phys)
 static void sh7705_flush_dcache_page(void *arg)
 {
 	struct page *page = arg;
-	struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping = __page_mapping(page);
 
 	if (mapping && !mapping_mapped(mapping))
 		clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index c50182cd2f64..5bd8b67e66f2 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -929,9 +929,9 @@ static inline void __local_flush_dcache_page(struct page *page)
 #ifdef DCACHE_ALIASING_POSSIBLE
 	__flush_dcache_page(page_address(page),
 			    ((tlb_type == spitfire) &&
-			     page_mapping(page) != NULL));
+			     __page_mapping(page) != NULL));
 #else
-	if (page_mapping(page) != NULL &&
+	if (__page_mapping(page) != NULL &&
 	    tlb_type == spitfire)
 		__flush_icache_page(__pa(page_address(page)));
 #endif
@@ -958,7 +958,7 @@ void smp_flush_dcache_page_impl(struct page *page, int cpu)
 
 		if (tlb_type == spitfire) {
 			data0 = ((u64)&xcall_flush_dcache_page_spitfire);
-			if (page_mapping(page) != NULL)
+			if (__page_mapping(page) != NULL)
 				data0 |= ((u64)1 << 32);
 		} else if (tlb_type == cheetah || tlb_type == cheetah_plus) {
 #ifdef DCACHE_ALIASING_POSSIBLE
@@ -994,7 +994,7 @@ void flush_dcache_page_all(struct mm_struct *mm, struct page *page)
 	pg_addr = page_address(page);
 	if (tlb_type == spitfire) {
 		data0 = ((u64)&xcall_flush_dcache_page_spitfire);
-		if (page_mapping(page) != NULL)
+		if (__page_mapping(page) != NULL)
 			data0 |= ((u64)1 << 32);
 	} else if (tlb_type == cheetah || tlb_type == cheetah_plus) {
 #ifdef DCACHE_ALIASING_POSSIBLE
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index a9f94e911e0a..6f0f3f2b04a9 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -206,9 +206,9 @@ inline void flush_dcache_page_impl(struct page *page)
 #ifdef DCACHE_ALIASING_POSSIBLE
 	__flush_dcache_page(page_address(page),
 			    ((tlb_type == spitfire) &&
-			     page_mapping(page) != NULL));
+			     __page_mapping(page) != NULL));
 #else
-	if (page_mapping(page) != NULL &&
+	if (__page_mapping(page) != NULL &&
 	    tlb_type == spitfire)
 		__flush_icache_page(__pa(page_address(page)));
 #endif
@@ -490,7 +490,7 @@ void flush_dcache_page(struct page *page)
 
 	this_cpu = get_cpu();
 
-	mapping = page_mapping(page);
+	mapping = __page_mapping(page);
 	if (mapping && !mapping_mapped(mapping)) {
 		int dirty = test_bit(PG_dcache_dirty, &page->flags);
 		if (dirty) {
diff --git a/arch/sparc/mm/tlb.c b/arch/sparc/mm/tlb.c
index 847ddffbf38a..5d7c13b88a42 100644
--- a/arch/sparc/mm/tlb.c
+++ b/arch/sparc/mm/tlb.c
@@ -128,7 +128,7 @@ void tlb_batch_add(struct mm_struct *mm, unsigned long vaddr,
 			goto no_cache_flush;
 
 		/* A real file page? */
-		mapping = page_mapping(page);
+		mapping = __page_mapping(page);
 		if (!mapping)
 			goto no_cache_flush;
 
diff --git a/arch/unicore32/mm/flush.c b/arch/unicore32/mm/flush.c
index 6d4c096ffa2a..def5142d16ea 100644
--- a/arch/unicore32/mm/flush.c
+++ b/arch/unicore32/mm/flush.c
@@ -83,7 +83,7 @@ void flush_dcache_page(struct page *page)
 	if (page == ZERO_PAGE(0))
 		return;
 
-	mapping = page_mapping(page);
+	mapping = __page_mapping(page);
 
 	if (mapping && !mapping_mapped(mapping))
 		clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/unicore32/mm/mmu.c b/arch/unicore32/mm/mmu.c
index 4f5a532bee13..2bd143b7aca3 100644
--- a/arch/unicore32/mm/mmu.c
+++ b/arch/unicore32/mm/mmu.c
@@ -503,7 +503,7 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long addr,
 	if (page == ZERO_PAGE(0))
 		return;
 
-	mapping = page_mapping(page);
+	mapping = __page_mapping(page);
 	if (!test_and_set_bit(PG_dcache_clean, &page->flags))
 		__flush_dcache_page(mapping, page);
 	if (mapping)
diff --git a/arch/xtensa/mm/cache.c b/arch/xtensa/mm/cache.c
index 57dc231a0709..17485819d03b 100644
--- a/arch/xtensa/mm/cache.c
+++ b/arch/xtensa/mm/cache.c
@@ -127,7 +127,7 @@ EXPORT_SYMBOL(copy_user_highpage);
 
 void flush_dcache_page(struct page *page)
 {
-	struct address_space *mapping = page_mapping(page);
+	struct address_space *mapping = __page_mapping(page);
 
 	/*
 	 * If we have a mapping but the page is not mapped to user-space
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c500bdfadf79..16d5e27b4438 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1146,6 +1146,7 @@ static inline pgoff_t page_index(struct page *page)
 }
 
 bool page_mapped(struct page *page);
+struct address_space *__page_mapping(struct page *page);
 struct address_space *page_mapping(struct page *page);
 
 /*
diff --git a/mm/util.c b/mm/util.c
index d800ce40816c..f47f3a1cc3f2 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -490,6 +490,26 @@ struct anon_vma *page_anon_vma(struct page *page)
 	return __page_rmapping(page);
 }
 
+/*
+ * For file cache pages, return the address_space, otherwise return NULL
+ */
+struct address_space *__page_mapping(struct page *page)
+{
+	struct address_space *mapping;
+
+	page = compound_head(page);
+
+	/* This happens if someone calls flush_dcache_page on slab page */
+	if (unlikely(PageSlab(page)))
+		return NULL;
+
+	mapping = page->mapping;
+	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
+		return NULL;
+
+	return (void *)((unsigned long)mapping & ~PAGE_MAPPING_FLAGS);
+}
+
 struct address_space *page_mapping(struct page *page)
 {
 	struct address_space *mapping;
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
