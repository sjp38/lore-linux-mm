Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C6B8F6B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 20:10:26 -0400 (EDT)
Date: Fri, 15 Jul 2011 02:10:21 +0200
From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/8] ARM: dma-mapping: use
 asm-generic/dma-mapping-common.h
Message-ID: <20110715001021.GM951@wantstofly.org>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <201106241736.43576.arnd@arndb.de>
 <000601cc34c4$430f91f0$c92eb5d0$%szyprowski@samsung.com>
 <201106271519.43581.arnd@arndb.de>
 <20110707120918.GF7810@wantstofly.org>
 <20110707123825.GO8286@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110707123825.GO8286@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>

On Thu, Jul 07, 2011 at 01:38:25PM +0100, Russell King - ARM Linux wrote:

> > > > > I suppose for the majority of the cases, the overhead of the indirect
> > > > > function call is near-zero, compared to the overhead of the cache
> > > > > management operation, so it would only make a difference for coherent
> > > > > systems without an IOMMU. Do we care about micro-optimizing those?
> > 
> > FWIW, when I was hacking on ARM access point routing performance some
> > time ago, turning the L1/L2 cache maintenance operations into inline
> > functions (inlined into the ethernet driver) gave me a significant and
> > measurable performance boost.
> 
> On what architecture?  Can you show what you did to gain that?

Patch is attached below.  It's an ugly product-specific hack, not
suitable for upstreaming in this form, etc etc, but IIRC it gave me
a ~5% improvement on packet routing.



>From 4e9ab8b1e5fd3a5d7abb3253b653a2990b377f97 Mon Sep 17 00:00:00 2001
From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Thu, 9 Apr 2009 02:28:54 +0200
Subject: [PATCH] Inline dma_cache_maint()

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 arch/arm/include/asm/cacheflush.h  |  174 ++++++++++++++++++++++++++++++++++++
 arch/arm/include/asm/dma-mapping.h |   24 +++++-
 arch/arm/mm/Kconfig                |    1 -
 arch/arm/mm/cache-feroceon-l2.c    |   10 ++-
 arch/arm/mm/dma-mapping.c          |   35 -------
 5 files changed, 205 insertions(+), 39 deletions(-)

diff --git a/arch/arm/include/asm/cacheflush.h b/arch/arm/include/asm/cacheflush.h
index 6cbd8fd..7cc28eb 100644
--- a/arch/arm/include/asm/cacheflush.h
+++ b/arch/arm/include/asm/cacheflush.h
@@ -228,9 +228,105 @@ extern struct cpu_cache_fns cpu_cache;
  * is visible to DMA, or data written by DMA to system memory is
  * visible to the CPU.
  */
+#if defined(CONFIG_ARCH_KIRKWOOD) || defined(CONFIG_ARCH_MV78XX0)
+#define CACHE_LINE_SIZE		32
+
+static inline void l1d_flush_mva(unsigned long addr)
+{
+	__asm__("mcr p15, 0, %0, c7, c14, 1" : : "r" (addr));
+}
+
+static inline void l1d_inv_mva_range(unsigned long start, unsigned long end)
+{
+	unsigned long flags;
+
+	raw_local_irq_save(flags);
+	__asm__("mcr p15, 5, %0, c15, c14, 0\n\t"
+		"mcr p15, 5, %1, c15, c14, 1"
+		: : "r" (start), "r" (end));
+	raw_local_irq_restore(flags);
+}
+
+static inline void l1d_clean_mva_range(unsigned long start, unsigned long end)
+{
+	unsigned long flags;
+
+	raw_local_irq_save(flags);
+	__asm__("mcr p15, 5, %0, c15, c13, 0\n\t"
+		"mcr p15, 5, %1, c15, c13, 1"
+		: : "r" (start), "r" (end));
+	raw_local_irq_restore(flags);
+}
+
+static inline void l1d_flush_mva_range(unsigned long start, unsigned long end)
+{
+	unsigned long flags;
+
+	raw_local_irq_save(flags);
+	__asm__("mcr p15, 5, %0, c15, c15, 0\n\t"
+		"mcr p15, 5, %1, c15, c15, 1"
+		: : "r" (start), "r" (end));
+	raw_local_irq_restore(flags);
+}
+
+static inline void dmac_inv_range(const void *_start, const void *_end)
+{
+	unsigned long start = (unsigned long)_start;
+	unsigned long end = (unsigned long)_end;
+
+	/*
+	 * Clean and invalidate partial first cache line.
+	 */
+	if (start & (CACHE_LINE_SIZE - 1)) {
+		l1d_flush_mva(start & ~(CACHE_LINE_SIZE - 1));
+		start = (start | (CACHE_LINE_SIZE - 1)) + 1;
+	}
+
+	/*
+	 * Clean and invalidate partial last cache line.
+	 */
+	if (start < end && end & (CACHE_LINE_SIZE - 1)) {
+		l1d_flush_mva(end & ~(CACHE_LINE_SIZE - 1));
+		end &= ~(CACHE_LINE_SIZE - 1);
+	}
+
+	/*
+	 * Invalidate all full cache lines between 'start' and 'end'.
+	 */
+	if (start < end)
+		l1d_inv_mva_range(start, end - CACHE_LINE_SIZE);
+
+	dsb();
+}
+
+static inline void dmac_clean_range(const void *_start, const void *_end)
+{
+	unsigned long start = (unsigned long)_start;
+	unsigned long end = (unsigned long)_end;
+
+	start &= ~(CACHE_LINE_SIZE - 1);
+	end = (end + CACHE_LINE_SIZE - 1) & ~(CACHE_LINE_SIZE - 1);
+	l1d_clean_mva_range(start, end - CACHE_LINE_SIZE);
+
+	dsb();
+}
+
+static inline void dmac_flush_range(const void *_start, const void *_end)
+{
+	unsigned long start = (unsigned long)_start;
+	unsigned long end = (unsigned long)_end;
+
+	start &= ~(CACHE_LINE_SIZE - 1);
+	end = (end + CACHE_LINE_SIZE - 1) & ~(CACHE_LINE_SIZE - 1);
+	l1d_flush_mva_range(start, end - CACHE_LINE_SIZE);
+
+	dsb();
+}
+#else
 #define dmac_inv_range			cpu_cache.dma_inv_range
 #define dmac_clean_range		cpu_cache.dma_clean_range
 #define dmac_flush_range		cpu_cache.dma_flush_range
+#endif
 
 #else
 
@@ -286,12 +382,90 @@ static inline void outer_flush_range(unsigned long start, unsigned long end)
 
 #else
 
+#if defined(CONFIG_ARCH_KIRKWOOD) || defined(CONFIG_ARCH_MV78XX0)
+static inline void l2_clean_pa_range(unsigned long start, unsigned long end)
+{
+	unsigned long flags;
+
+	raw_local_irq_save(flags);
+	__asm__("mcr p15, 1, %0, c15, c9, 4\n\t"
+		"mcr p15, 1, %1, c15, c9, 5"
+		: : "r" (__phys_to_virt(start)), "r" (__phys_to_virt(end)));
+	raw_local_irq_restore(flags);
+}
+
+static inline void l2_clean_inv_pa(unsigned long addr)
+{
+	__asm__("mcr p15, 1, %0, c15, c10, 3" : : "r" (addr));
+}
+
+static inline void l2_inv_pa_range(unsigned long start, unsigned long end)
+{
+	unsigned long flags;
+
+	raw_local_irq_save(flags);
+	__asm__("mcr p15, 1, %0, c15, c11, 4\n\t"
+		"mcr p15, 1, %1, c15, c11, 5"
+		: : "r" (__phys_to_virt(start)), "r" (__phys_to_virt(end)));
+	raw_local_irq_restore(flags);
+}
+
+static inline void outer_inv_range(unsigned long start, unsigned long end)
+{
+	/*
+	 * Clean and invalidate partial first cache line.
+	 */
+	if (start & (CACHE_LINE_SIZE - 1)) {
+		l2_clean_inv_pa(start & ~(CACHE_LINE_SIZE - 1));
+		start = (start | (CACHE_LINE_SIZE - 1)) + 1;
+	}
+
+	/*
+	 * Clean and invalidate partial last cache line.
+	 */
+	if (start < end && end & (CACHE_LINE_SIZE - 1)) {
+		l2_clean_inv_pa(end & ~(CACHE_LINE_SIZE - 1));
+		end &= ~(CACHE_LINE_SIZE - 1);
+	}
+
+	/*
+	 * Invalidate all full cache lines between 'start' and 'end'.
+	 */
+	if (start < end)
+		l2_inv_pa_range(start, end - CACHE_LINE_SIZE);
+
+	dsb();
+}
+
+static inline void outer_clean_range(unsigned long start, unsigned long end)
+{
+	start &= ~(CACHE_LINE_SIZE - 1);
+	end = (end + CACHE_LINE_SIZE - 1) & ~(CACHE_LINE_SIZE - 1);
+	if (start != end)
+		l2_clean_pa_range(start, end - CACHE_LINE_SIZE);
+
+	dsb();
+}
+
+static inline void outer_flush_range(unsigned long start, unsigned long end)
+{
+	start &= ~(CACHE_LINE_SIZE - 1);
+	end = (end + CACHE_LINE_SIZE - 1) & ~(CACHE_LINE_SIZE - 1);
+	if (start != end) {
+		l2_clean_pa_range(start, end - CACHE_LINE_SIZE);
+		l2_inv_pa_range(start, end - CACHE_LINE_SIZE);
+	}
+
+	dsb();
+}
+#else
 static inline void outer_inv_range(unsigned long start, unsigned long end)
 { }
 static inline void outer_clean_range(unsigned long start, unsigned long end)
 { }
 static inline void outer_flush_range(unsigned long start, unsigned long end)
 { }
+#endif
 
 #endif
 
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 22cb14e..10b517c 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -6,6 +6,7 @@
 #include <linux/mm_types.h>
 #include <linux/scatterlist.h>
 
+#include <asm/cacheflush.h>
 #include <asm-generic/dma-coherent.h>
 #include <asm/memory.h>
 
@@ -56,7 +57,28 @@ static inline dma_addr_t virt_to_dma(struct device *dev, void *addr)
  * platforms with CONFIG_DMABOUNCE.
  * Use the driver DMA support - see dma-mapping.h (dma_sync_*)
  */
-extern void dma_cache_maint(const void *kaddr, size_t size, int rw);
+static inline void
+dma_cache_maint(const void *start, size_t size, int direction)
+{
+//	BUG_ON(!virt_addr_valid(start) || !virt_addr_valid(end - 1));
+
+	switch (direction) {
+	case DMA_FROM_DEVICE:		/* invalidate only */
+		dmac_inv_range(start, start + size);
+		outer_inv_range(__pa(start), __pa(start) + size);
+		break;
+	case DMA_TO_DEVICE:		/* writeback only */
+		dmac_clean_range(start, start + size);
+		outer_clean_range(__pa(start), __pa(start) + size);
+		break;
+	case DMA_BIDIRECTIONAL:		/* writeback and invalidate */
+		dmac_flush_range(start, start + size);
+		outer_flush_range(__pa(start), __pa(start) + size);
+		break;
+//	default:
+//		BUG();
+	}
+}
 
 /*
  * Return whether the given device DMA address mask can be supported
diff --git a/arch/arm/mm/Kconfig b/arch/arm/mm/Kconfig
index d490f37..3e4c526 100644
--- a/arch/arm/mm/Kconfig
+++ b/arch/arm/mm/Kconfig
@@ -690,7 +690,6 @@ config CACHE_FEROCEON_L2
 	bool "Enable the Feroceon L2 cache controller"
 	depends on ARCH_KIRKWOOD || ARCH_MV78XX0
 	default y
-	select OUTER_CACHE
 	help
 	  This option enables the Feroceon L2 cache controller.
 
diff --git a/arch/arm/mm/cache-feroceon-l2.c b/arch/arm/mm/cache-feroceon-l2.c
index 355c2a1..f84e34f 100644
--- a/arch/arm/mm/cache-feroceon-l2.c
+++ b/arch/arm/mm/cache-feroceon-l2.c
@@ -17,6 +17,9 @@
 #include <plat/cache-feroceon-l2.h>
 
 
+static int l2_wt_override;
+
+#if 0
 /*
  * Low-level cache maintenance operations.
  *
@@ -94,12 +97,14 @@ static inline void l2_inv_pa_range(unsigned long start, unsigned long end)
 {
 	l2_inv_mva_range(__phys_to_virt(start), __phys_to_virt(end));
 }
+#endif
 
 static inline void l2_inv_all(void)
 {
 	__asm__("mcr p15, 1, %0, c15, c11, 0" : : "r" (0));
 }
 
+#if 0
 /*
  * Linux primitives.
  *
@@ -110,8 +115,6 @@ static inline void l2_inv_all(void)
 #define CACHE_LINE_SIZE		32
 #define MAX_RANGE_SIZE		1024
 
-static int l2_wt_override;
-
 static unsigned long calc_range_end(unsigned long start, unsigned long end)
 {
 	unsigned long range_end;
@@ -204,6 +207,7 @@ static void feroceon_l2_flush_range(unsigned long start, unsigned long end)
 
 	dsb();
 }
+#endif
 
 
 /*
@@ -318,9 +322,11 @@ void __init feroceon_l2_init(int __l2_wt_override)
 
 	disable_l2_prefetch();
 
+#if 0
 	outer_cache.inv_range = feroceon_l2_inv_range;
 	outer_cache.clean_range = feroceon_l2_clean_range;
 	outer_cache.flush_range = feroceon_l2_flush_range;
+#endif
 
 	enable_l2();
 
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index f1ef561..d866150 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -482,41 +482,6 @@ static int __init consistent_init(void)
 
 core_initcall(consistent_init);
 
-/*
- * Make an area consistent for devices.
- * Note: Drivers should NOT use this function directly, as it will break
- * platforms with CONFIG_DMABOUNCE.
- * Use the driver DMA support - see dma-mapping.h (dma_sync_*)
- */
-void dma_cache_maint(const void *start, size_t size, int direction)
-{
-	void (*inner_op)(const void *, const void *);
-	void (*outer_op)(unsigned long, unsigned long);
-
-	BUG_ON(!virt_addr_valid(start) || !virt_addr_valid(start + size - 1));
-
-	switch (direction) {
-	case DMA_FROM_DEVICE:		/* invalidate only */
-		inner_op = dmac_inv_range;
-		outer_op = outer_inv_range;
-		break;
-	case DMA_TO_DEVICE:		/* writeback only */
-		inner_op = dmac_clean_range;
-		outer_op = outer_clean_range;
-		break;
-	case DMA_BIDIRECTIONAL:		/* writeback and invalidate */
-		inner_op = dmac_flush_range;
-		outer_op = outer_flush_range;
-		break;
-	default:
-		BUG();
-	}
-
-	inner_op(start, start + size);
-	outer_op(__pa(start), __pa(start) + size);
-}
-EXPORT_SYMBOL(dma_cache_maint);
-
 /**
  * dma_map_sg - map a set of SG buffers for streaming mode DMA
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
