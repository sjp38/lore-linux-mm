Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EACF66B0092
	for <linux-mm@kvack.org>; Wed, 20 May 2009 14:30:46 -0400 (EDT)
Date: Wed, 20 May 2009 11:30:45 -0700
From: "Larry H." <research@subreption.com>
Subject: [patch 0/5] Support for sanitization flag in low-level page
	allocator
Message-ID: <20090520183045.GB10547@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

This patch adds support for the SENSITIVE flag to the low level page
allocator. An additional GFP flag is added for use with higher level
allocators (GFP_SENSITIVE, which implies GFP_ZERO).

The code is largely based off the memory sanitization feature in the
PaX project (licensed under the GPL v2 terms), and allows fine grained
marking of pages for sanitization on allocation and release time, as an
opt-in feature (instead of its opt-all counterpart in PaX).

This avoids leaking sensitive information when memory is released to
the system after use, for example in cryptographic subsystems.

The next patches in this set deploy this flag for different
subsystems that could potentially leak cryptographic secrets or other
confidential information by means of an information leak or other kinds
of security bugs (ex. use of uninitialized variables or use-after-free),
besides extending the remanence of this data on memory (allowing
Iceman/coldboot attacks possible).

The "Shredding Your Garbage: Reducing Data Lifetime Through Secure
Deallocation" paper by Jim Chow et. al from the Stanford University
Department of Computer Science, explains the security implications of
insecure deallocation, and provides extensive information with figures
and applications thoroughly analyzed for this behavior [1]. More recently
this issue came to widespread attention when the "Lest We Remember:
Cold Boot Attacks on Encryption Keys" (by Halderman et. al) paper was
published [2].

This patch has been tested on x86 and amd64, with and without HIGHMEM.

	[1] http://www.stanford.edu/~blp/papers/shredding.html
	[2] http://citp.princeton.edu/memory/

Signed-off-by: Larry H. <research@subreption.com>

---
 arch/alpha/include/asm/kmap_types.h    |    3 ++-
 arch/arm/include/asm/kmap_types.h      |    1 +
 arch/avr32/include/asm/kmap_types.h    |    3 ++-
 arch/blackfin/include/asm/kmap_types.h |    1 +
 arch/cris/include/asm/kmap_types.h     |    1 +
 arch/h8300/include/asm/kmap_types.h    |    1 +
 arch/ia64/include/asm/kmap_types.h     |    3 ++-
 arch/m68k/include/asm/kmap_types_mm.h  |    1 +
 arch/m68k/include/asm/kmap_types_no.h  |    1 +
 arch/mips/include/asm/kmap_types.h     |    3 ++-
 arch/parisc/include/asm/kmap_types.h   |    3 ++-
 arch/powerpc/include/asm/kmap_types.h  |    1 +
 arch/s390/include/asm/kmap_types.h     |    1 +
 arch/sh/include/asm/kmap_types.h       |    3 ++-
 arch/sparc/include/asm/kmap_types.h    |    1 +
 arch/um/include/asm/kmap_types.h       |    1 +
 arch/x86/include/asm/kmap_types.h      |    3 ++-
 arch/xtensa/include/asm/kmap_types.h   |    1 +
 include/asm-frv/kmap_types.h           |    1 +
 include/asm-m32r/kmap_types.h          |    3 ++-
 include/asm-mn10300/kmap_types.h       |    1 +
 include/linux/gfp.h                    |   17 +++++++++++++++++
 include/linux/highmem.h                |   12 ++++++++++++
 include/linux/page-flags.h             |    2 ++
 include/linux/slab.h                   |    1 +
 mm/Kconfig                             |   20 ++++++++++++++++++++
 mm/page_alloc.c                        |   22 ++++++++++++++++++++++
 mm/slab.c                              |    8 +++++++-
 mm/slub.c                              |    3 +++
 29 files changed, 113 insertions(+), 9 deletions(-)

Index: linux-2.6/arch/alpha/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/alpha/include/asm/kmap_types.h
+++ linux-2.6/arch/alpha/include/asm/kmap_types.h
@@ -24,7 +24,8 @@ D(9)	KM_IRQ0,
 D(10)	KM_IRQ1,
 D(11)	KM_SOFTIRQ0,
 D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
+D(13)  KM_CLEARPAGE,
+D(14)  KM_TYPE_NR
 };
 
 #undef D
Index: linux-2.6/arch/arm/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/arm/include/asm/kmap_types.h
+++ linux-2.6/arch/arm/include/asm/kmap_types.h
@@ -18,6 +18,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/avr32/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/avr32/include/asm/kmap_types.h
+++ linux-2.6/arch/avr32/include/asm/kmap_types.h
@@ -22,7 +22,8 @@ D(10)	KM_IRQ0,
 D(11)	KM_IRQ1,
 D(12)	KM_SOFTIRQ0,
 D(13)	KM_SOFTIRQ1,
-D(14)	KM_TYPE_NR
+D(14)	KM_CLEARPAGE,
+D(15)	KM_TYPE_NR
 };
 
 #undef D
Index: linux-2.6/arch/blackfin/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/blackfin/include/asm/kmap_types.h
+++ linux-2.6/arch/blackfin/include/asm/kmap_types.h
@@ -15,6 +15,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/cris/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/cris/include/asm/kmap_types.h
+++ linux-2.6/arch/cris/include/asm/kmap_types.h
@@ -19,6 +19,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/h8300/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/h8300/include/asm/kmap_types.h
+++ linux-2.6/arch/h8300/include/asm/kmap_types.h
@@ -15,6 +15,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/ia64/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/ia64/include/asm/kmap_types.h
+++ linux-2.6/arch/ia64/include/asm/kmap_types.h
@@ -22,7 +22,8 @@ D(9)	KM_IRQ0,
 D(10)	KM_IRQ1,
 D(11)	KM_SOFTIRQ0,
 D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
+D(13)	KM_CLEARPAGE,
+D(14)	KM_TYPE_NR
 };
 
 #undef D
Index: linux-2.6/arch/m68k/include/asm/kmap_types_mm.h
===================================================================
--- linux-2.6.orig/arch/m68k/include/asm/kmap_types_mm.h
+++ linux-2.6/arch/m68k/include/asm/kmap_types_mm.h
@@ -15,6 +15,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/m68k/include/asm/kmap_types_no.h
===================================================================
--- linux-2.6.orig/arch/m68k/include/asm/kmap_types_no.h
+++ linux-2.6/arch/m68k/include/asm/kmap_types_no.h
@@ -15,6 +15,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/mips/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/mips/include/asm/kmap_types.h
+++ linux-2.6/arch/mips/include/asm/kmap_types.h
@@ -22,7 +22,8 @@ D(9)	KM_IRQ0,
 D(10)	KM_IRQ1,
 D(11)	KM_SOFTIRQ0,
 D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
+D(13)	KM_CLEARPAGE,
+D(14)	KM_TYPE_NR
 };
 
 #undef D
Index: linux-2.6/arch/parisc/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/parisc/include/asm/kmap_types.h
+++ linux-2.6/arch/parisc/include/asm/kmap_types.h
@@ -22,7 +22,8 @@ D(9)	KM_IRQ0,
 D(10)	KM_IRQ1,
 D(11)	KM_SOFTIRQ0,
 D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
+D(13)	KM_CLEARPAGE,
+D(14)	KM_TYPE_NR
 };
 
 #undef D
Index: linux-2.6/arch/powerpc/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/powerpc/include/asm/kmap_types.h
+++ linux-2.6/arch/powerpc/include/asm/kmap_types.h
@@ -26,6 +26,7 @@ enum km_type {
 	KM_SOFTIRQ1,
 	KM_PPC_SYNC_PAGE,
 	KM_PPC_SYNC_ICACHE,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/s390/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/s390/include/asm/kmap_types.h
+++ linux-2.6/arch/s390/include/asm/kmap_types.h
@@ -16,6 +16,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,	
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/sh/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/sh/include/asm/kmap_types.h
+++ linux-2.6/arch/sh/include/asm/kmap_types.h
@@ -24,7 +24,8 @@ D(9)	KM_IRQ0,
 D(10)	KM_IRQ1,
 D(11)	KM_SOFTIRQ0,
 D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
+D(13)	KM_CLEARPAGE,
+D(14)	KM_TYPE_NR
 };
 
 #undef D
Index: linux-2.6/arch/sparc/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/sparc/include/asm/kmap_types.h
+++ linux-2.6/arch/sparc/include/asm/kmap_types.h
@@ -19,6 +19,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/um/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/um/include/asm/kmap_types.h
+++ linux-2.6/arch/um/include/asm/kmap_types.h
@@ -23,6 +23,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/arch/x86/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/kmap_types.h
+++ linux-2.6/arch/x86/include/asm/kmap_types.h
@@ -21,7 +21,8 @@ D(9)	KM_IRQ0,
 D(10)	KM_IRQ1,
 D(11)	KM_SOFTIRQ0,
 D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
+D(13)	KM_CLEARPAGE,
+D(14)	KM_TYPE_NR
 };
 
 #undef D
Index: linux-2.6/arch/xtensa/include/asm/kmap_types.h
===================================================================
--- linux-2.6.orig/arch/xtensa/include/asm/kmap_types.h
+++ linux-2.6/arch/xtensa/include/asm/kmap_types.h
@@ -25,6 +25,7 @@ enum km_type {
   KM_IRQ1,
   KM_SOFTIRQ0,
   KM_SOFTIRQ1,
+  KM_CLEARPAGE,
   KM_TYPE_NR
 };
 
Index: linux-2.6/include/asm-frv/kmap_types.h
===================================================================
--- linux-2.6.orig/include/asm-frv/kmap_types.h
+++ linux-2.6/include/asm-frv/kmap_types.h
@@ -23,6 +23,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/include/asm-m32r/kmap_types.h
===================================================================
--- linux-2.6.orig/include/asm-m32r/kmap_types.h
+++ linux-2.6/include/asm-m32r/kmap_types.h
@@ -21,7 +21,8 @@ D(9)	KM_IRQ0,
 D(10)	KM_IRQ1,
 D(11)	KM_SOFTIRQ0,
 D(12)	KM_SOFTIRQ1,
-D(13)	KM_TYPE_NR
+D(13)	KM_CLEARPAGE,
+D(14)	KM_TYPE_NR
 };
 
 #undef D
Index: linux-2.6/include/asm-mn10300/kmap_types.h
===================================================================
--- linux-2.6.orig/include/asm-mn10300/kmap_types.h
+++ linux-2.6/include/asm-mn10300/kmap_types.h
@@ -25,6 +25,7 @@ enum km_type {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
+	KM_CLEARPAGE,
 	KM_TYPE_NR
 };
 
Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h
+++ linux-2.6/include/linux/gfp.h
@@ -50,6 +50,7 @@ struct vm_area_struct;
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
 #define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
+#define __GFP_SENSITIVE	((__force gfp_t)0x200000u)  /* Page contains sensitive information */
 
 #define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -69,6 +70,7 @@ struct vm_area_struct;
 #define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 				 __GFP_HARDWALL | __GFP_HIGHMEM | \
 				 __GFP_MOVABLE)
+#define GFP_SENSITIVE	(__GFP_SENSITIVE | __GFP_ZERO)
 
 #ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
@@ -131,6 +133,21 @@ static inline enum zone_type gfp_zone(gf
 	return ZONE_NORMAL;
 }
 
+#ifdef CONFIG_PAGE_SENSITIVE
+static inline int gfp_sensitive(gfp_t flags)
+{
+	if (flags & __GFP_SENSITIVE)
+		return 1;
+
+	return 0;
+}
+#else
+static inline int gfp_sensitive(gfp_t flags)
+{
+	return 0;
+}
+#endif
+
 /*
  * There is only one page-allocator function, and two main namespaces to
  * it. The alloc_page*() variants return 'struct page *' and as such
Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h
+++ linux-2.6/include/linux/highmem.h
@@ -124,6 +124,18 @@ static inline void clear_highpage(struct
 	kunmap_atomic(kaddr, KM_USER0);
 }
 
+static inline void sanitize_highpage(struct page *page)
+{
+	void *kaddr;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	kaddr = kmap_atomic(page, KM_CLEARPAGE);
+	clear_page(kaddr);
+	kunmap_atomic(kaddr, KM_CLEARPAGE);
+	local_irq_restore(flags);
+}
+
 static inline void zero_user_segments(struct page *page,
 	unsigned start1, unsigned end1,
 	unsigned start2, unsigned end2)
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -101,6 +101,7 @@ enum pageflags {
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
 #endif
+	PG_sensitive,		/* Page holds sensitive data */
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -195,6 +196,7 @@ PAGEFLAG(Reserved, reserved) __CLEARPAGE
 PAGEFLAG(Private, private) __CLEARPAGEFLAG(Private, private)
 	__SETPAGEFLAG(Private, private)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
+PAGEFLAG(Sensitive, sensitive)
 
 __PAGEFLAG(SlobPage, slob_page)
 __PAGEFLAG(SlobFree, slob_free)
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h
+++ linux-2.6/include/linux/slab.h
@@ -23,6 +23,7 @@
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
+#define SLAB_SENSITIVE		0x00080000UL	/* Memory will hold sensitive information */
 /*
  * SLAB_DESTROY_BY_RCU - **WARNING** READ THIS!
  *
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -155,6 +155,26 @@ config PAGEFLAGS_EXTENDED
 	def_bool y
 	depends on 64BIT || SPARSEMEM_VMEMMAP || !NUMA || !SPARSEMEM
 
+config PAGE_SENSITIVE
+	bool "Support for selective page sanitization"
+	help
+	 This option provides support for honoring the sensitive bit
+	 in the low level page allocator. This bit is used to mark
+	 pages that will contain sensitive information (such as
+	 cryptographic secrets and credentials).
+
+	 Pages marked with the sensitive bit will be sanitized upon
+	 release, to prevent information leaks and data remanence that
+	 could allow Iceman/coldboot attacks to reveal such data.
+
+	 If you are unsure, select N. This option might introduce a
+	 minimal performance impact on those subsystems that make
+	 use of the flag associated with the sensitive bit.
+
+	 If you use the cryptographic API or want to prevent tty
+	 information leaks locally, you most likely want to enable
+	 this.
+
 # Heavily threaded applications may benefit from splitting the mm-wide
 # page_table_lock, so that faults on different parts of the user address
 # space can be handled with less contention: split it at this NR_CPUS.
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -545,6 +545,7 @@ static void free_one_page(struct zone *z
 
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
+	unsigned long index = 1UL << order;
 	unsigned long flags;
 	int i;
 	int bad = 0;
@@ -559,6 +560,18 @@ static void __free_pages_ok(struct page 
 		debug_check_no_obj_freed(page_address(page),
 					   PAGE_SIZE << order);
 	}
+
+	/*
+	 * Page has the SENSITIVE flag set. We zero the memory
+	 * and clear the flag bit.
+	 */
+	if (PageSensitive(page)) {
+		for (; index; --index)
+			sanitize_highpage(page + index - 1);
+
+		ClearPageSensitive(page);
+	}
+
 	arch_free_page(page, order);
 	kernel_map_pages(page, 1 << order, 0);
 
@@ -650,6 +663,9 @@ static int prep_new_page(struct page *pa
 	if (gfp_flags & __GFP_ZERO)
 		prep_zero_page(page, order, gfp_flags);
 
+	if (gfp_sensitive(gfp_flags))
+		SetPageSensitive(page);
+
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
 
@@ -1009,6 +1025,12 @@ static void free_hot_cold_page(struct pa
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
 		debug_check_no_obj_freed(page_address(page), PAGE_SIZE);
 	}
+
+	if (PageSensitive(page)) {
+		sanitize_highpage(page);
+		ClearPageSensitive(page);
+	}
+
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -2270,7 +2270,11 @@ kmem_cache_create (const char *name, siz
 	align = ralign;
 
 	/* Get cache's description obj. */
-	cachep = kmem_cache_zalloc(&cache_cache, GFP_KERNEL);
+	if (flags & SLAB_SENSITIVE)
+		cachep = kmem_cache_zalloc(&cache_cache, GFP_KERNEL | GFP_SENSITIVE);
+	else
+		cachep = kmem_cache_zalloc(&cache_cache, GFP_KERNEL);
+
 	if (!cachep)
 		goto oops;
 
@@ -2356,6 +2360,8 @@ kmem_cache_create (const char *name, siz
 	cachep->gfpflags = 0;
 	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
 		cachep->gfpflags |= GFP_DMA;
+	if (flags & SLAB_SENSITIVE)
+		cachep->gfpflags |= GFP_SENSITIVE;
 	cachep->buffer_size = size;
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -2292,6 +2292,9 @@ static int calculate_sizes(struct kmem_c
 	if (s->flags & SLAB_RECLAIM_ACCOUNT)
 		s->allocflags |= __GFP_RECLAIMABLE;
 
+	if (s->flags & SLAB_SENSITIVE)
+		s->allocflags |= GFP_SENSITIVE;
+
 	/*
 	 * Determine the number of objects per slab
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
