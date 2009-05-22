Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 62A136B004F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 19:25:58 -0400 (EDT)
Date: Fri, 22 May 2009 16:25:26 -0700
From: "Larry H." <research@subreption.com>
Subject: [PATCH] Support for kernel memory sanitization
Message-ID: <20090522232526.GG13971@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com> <20090522143914.2019dd47@lxorguk.ukuu.org.uk> <20090522180351.GC13971@oblivion.subreption.com> <20090522192158.28fe412e@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090522192158.28fe412e@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

[PATCH] Support for kernel memory sanitization

This patch adds support for the CONFIDENTIAL flag to the SLAB and SLUB
allocators. An additional GFP flag is added for use with higher level
allocators (GFP_CONFIDENTIAL, which implies GFP_ZERO).

A boot command line option (sanitize_mem) is added for the page
allocator to perform sanitization of all pages upon release and
allocation.

The code is largely based off the memory sanitization feature in the
PaX project (licensed under the GPL v2 terms) and the original
PG_sensitive patch which allowed fine-grained marking of pages using
a page flag. The lack of a page flag makes the gfp flag mostly useless,
since we can't track pages with the sensitive/confidential bit, and
properly sanitize them on release. The only way to overcome this
limitation is to enable the sanitize_mem boot option and perform
unconditional page sanitization.

This avoids leaking sensitive information when memory is released to
the system after use, for example in cryptographic subsystems. More
specifically, the following threats are addressed:

	1. Information leaks in use-after-free or uninitialized
	variable usage scenarios, such as CVE-2005-0400,
	CVE-2009-0787 and CVE-2007-6417.

	2. Data remanence based attacks, such as Iceman/Coldboot,
	which combine cold rebooting and memory image scanning
	to extract cryptographic secrets (ex. detecting AES key
	expansion blocks, RSA key patterns, etc) or other
	confidential information.

	3. Re-allocation based information leaks, especially in the
	SLAB/SLUB allocators which use LIFO caches and might expose
	sensitive data out of context (when a caller allocates an
	object and receives a pointer to a location which was used
	previously by another user).

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
	[3] http://marc.info/?l=linux-mm&m=124284428226461&w=2
	[4] http://marc.info/?t=124284431000002&r=1&w=2

Signed-off-by: Larry H. <research@subreption.com>

---
 Documentation/kernel-parameters.txt    |    2 ++
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
 include/linux/gfp.h                    |    2 ++
 include/linux/highmem.h                |   12 ++++++++++++
 include/linux/mm.h                     |    2 ++
 include/linux/slab.h                   |    1 +
 mm/page_alloc.c                        |   30 +++++++++++++++++++++++++++++-
 mm/slab.c                              |   13 +++++++++++--
 mm/slub.c                              |   24 ++++++++++++++++++++++++
 29 files changed, 112 insertions(+), 11 deletions(-)

Index: linux-2.6/Documentation/kernel-parameters.txt
===================================================================
--- linux-2.6.orig/Documentation/kernel-parameters.txt
+++ linux-2.6/Documentation/kernel-parameters.txt
@@ -2494,6 +2494,8 @@ and is between 256 and 4096 characters. 
 	norandmaps	Don't use address space randomization.  Equivalent to
 			echo 0 > /proc/sys/kernel/randomize_va_space
 
+	sanitize_mem	Enables sanitization of all allocated pages.
+
 ______________________________________________________________________
 
 TODO:
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
+#define __GFP_CONFIDENTIAL	((__force gfp_t)0x200000u)  /* Page contains sensitive information */
 
 #define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -69,6 +70,7 @@ struct vm_area_struct;
 #define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 				 __GFP_HARDWALL | __GFP_HIGHMEM | \
 				 __GFP_MOVABLE)
+#define GFP_CONFIDENTIAL	(__GFP_CONFIDENTIAL | __GFP_ZERO)
 
 #ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
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
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -25,6 +25,7 @@ extern unsigned long max_mapnr;
 #endif
 
 extern unsigned long num_physpages;
+extern int sanitize_all_mem;
 extern void * high_memory;
 extern int page_cluster;
 
@@ -104,6 +105,7 @@ extern unsigned int kobjsize(const void 
 #define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
+#define VM_CONFIDENTIAL	0x40000000	/* Will contain sensitive data */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h
+++ linux-2.6/include/linux/slab.h
@@ -23,6 +23,7 @@
 #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
 #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
+#define SLAB_CONFIDENTIAL		0x00080000UL	/* Memory will hold sensitive information */
 /*
  * SLAB_DESTROY_BY_RCU - **WARNING** READ THIS!
  *
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -123,6 +123,7 @@ int min_free_kbytes = 1024;
 unsigned long __meminitdata nr_kernel_pages;
 unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
+int sanitize_all_mem;
 
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
   /*
@@ -221,6 +222,17 @@ static inline int bad_range(struct zone 
 }
 #endif
 
+static __init int setup_page_sanitization(char *s)
+{
+	if (s) {
+		sanitize_all_mem = 1;
+		return 1;
+	}
+
+	return 0;
+}
+early_param("sanitize_mem", setup_page_sanitization);
+
 static void bad_page(struct page *page)
 {
 	static unsigned long resume;
@@ -545,6 +557,7 @@ static void free_one_page(struct zone *z
 
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
+	unsigned long index = 1UL << order;
 	unsigned long flags;
 	int i;
 	int bad = 0;
@@ -559,6 +572,16 @@ static void __free_pages_ok(struct page 
 		debug_check_no_obj_freed(page_address(page),
 					   PAGE_SIZE << order);
 	}
+
+	/*
+	 * Page sanitization is enabled, let's clear the page contents before
+	 * release.
+	 */
+	if (sanitize_all_mem) {
+		for (; index; --index)
+			sanitize_highpage(page + index - 1);
+	}
+
 	arch_free_page(page, order);
 	kernel_map_pages(page, 1 << order, 0);
 
@@ -647,7 +670,8 @@ static int prep_new_page(struct page *pa
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
 
-	if (gfp_flags & __GFP_ZERO)
+	if (((gfp_flags & __GFP_ZERO) || (gfp_flags & __GFP_CONFIDENTIAL))
+		|| sanitize_all_mem)
 		prep_zero_page(page, order, gfp_flags);
 
 	if (order && (gfp_flags & __GFP_COMP))
@@ -1009,6 +1033,10 @@ static void free_hot_cold_page(struct pa
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
 		debug_check_no_obj_freed(page_address(page), PAGE_SIZE);
 	}
+
+	if (sanitize_all_mem)
+		sanitize_highpage(page);
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
+	if (flags & SLAB_CONFIDENTIAL)
+		cachep = kmem_cache_zalloc(&cache_cache, GFP_KERNEL | GFP_CONFIDENTIAL);
+	else
+		cachep = kmem_cache_zalloc(&cache_cache, GFP_KERNEL);
+
 	if (!cachep)
 		goto oops;
 
@@ -2356,6 +2360,8 @@ kmem_cache_create (const char *name, siz
 	cachep->gfpflags = 0;
 	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
 		cachep->gfpflags |= GFP_DMA;
+	if (flags & SLAB_CONFIDENTIAL)
+		cachep->gfpflags |= GFP_CONFIDENTIAL;
 	cachep->buffer_size = size;
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
 
@@ -3350,7 +3356,7 @@ __cache_alloc_node(struct kmem_cache *ca
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
-	if (unlikely((flags & __GFP_ZERO) && ptr))
+	if (unlikely(((flags & __GFP_ZERO) || (flags && __GFP_CONFIDENTIAL)) && ptr))
 		memset(ptr, 0, obj_size(cachep));
 
 	return ptr;
@@ -3519,6 +3525,9 @@ static inline void __cache_free(struct k
 	check_irq_off();
 	objp = cache_free_debugcheck(cachep, objp, __builtin_return_address(0));
 
+	if (unlikely(cachep->flags & SLAB_CONFIDENTIAL))
+		memset(objp, 0, obj_size(cachep));
+
 	/*
 	 * Skip calling cache_free_alien() when the platform is not numa.
 	 * This will avoid cache misses that happen while accessing slabp (which
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -1135,6 +1135,9 @@ static struct page *new_slab(struct kmem
 
 	start = page_address(page);
 
+	if (unlikely(s->flags & SLAB_CONFIDENTIAL))
+		memset(start, 0, PAGE_SIZE << compound_order(page));
+
 	if (unlikely(s->flags & SLAB_POISON))
 		memset(start, POISON_INUSE, PAGE_SIZE << compound_order(page));
 
@@ -1646,6 +1649,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
 static void __slab_free(struct kmem_cache *s, struct page *page,
 			void *x, unsigned long addr, unsigned int offset)
 {
+	int objsize;
 	void *prior;
 	void **object = (void *)x;
 	struct kmem_cache_cpu *c;
@@ -1662,6 +1666,23 @@ checks_ok:
 	page->freelist = object;
 	page->inuse--;
 
+	if (s->flags & SLAB_CONFIDENTIAL) {
+		/* Size calculation based off ksize() */
+		objsize = s->size;
+
+		if (unlikely(!PageSlab(page))) {
+			WARN_ON(!PageCompound(page));
+			objsize = PAGE_SIZE << compound_order(page);
+		} else {
+			if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
+				objsize = s->objsize;
+			else if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
+				objsize = s->inuse;
+		}
+
+		memset(x, 0, objsize);
+	}
+
 	if (unlikely(PageSlubFrozen(page))) {
 		stat(c, FREE_FROZEN);
 		goto out_unlock;
@@ -2292,6 +2313,9 @@ static int calculate_sizes(struct kmem_c
 	if (s->flags & SLAB_RECLAIM_ACCOUNT)
 		s->allocflags |= __GFP_RECLAIMABLE;
 
+	if (s->flags & SLAB_CONFIDENTIAL)
+		s->allocflags |= GFP_CONFIDENTIAL;
+
 	/*
 	 * Determine the number of objects per slab
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
