Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 966286B004D
	for <linux-mm@kvack.org>; Sat, 23 May 2009 14:22:29 -0400 (EDT)
Date: Sat, 23 May 2009 11:21:41 -0700
From: "Larry H." <research@subreption.com>
Subject: [PATCH] Support for unconditional page sanitization
Message-ID: <20090523182141.GK13971@oblivion.subreption.com>
References: <20090520183045.GB10547@oblivion.subreption.com> <4A15A8C7.2030505@redhat.com> <20090522073436.GA3612@elte.hu> <20090522113809.GB13971@oblivion.subreption.com> <20090522143914.2019dd47@lxorguk.ukuu.org.uk> <20090522180351.GC13971@oblivion.subreption.com> <20090522192158.28fe412e@lxorguk.ukuu.org.uk> <20090522234031.GH13971@oblivion.subreption.com> <20090523090910.3d6c2e85@lxorguk.ukuu.org.uk> <20090523085653.0ad217f8@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090523085653.0ad217f8@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

[PATCH] Support for unconditional page sanitization

A boot command line option (sanitize_mem) is added for the page
allocator to perform sanitization of all pages upon release.

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

The code is largely based off the memory sanitization feature in the
PaX project (licensed under the GPL v2 terms) and the original
PG_sensitive patch which allowed fine-grained marking of pages using
a page flag.

This patch has been tested on x86 and amd64, with and without HIGHMEM.

	[1] http://www.stanford.edu/~blp/papers/shredding.html
	[2] http://citp.princeton.edu/memory/
	[3] http://marc.info/?l=linux-mm&m=124284428226461&w=2
	[4] http://marc.info/?t=124284431000002&r=1&w=2

Signed-off-by: Larry Highsmith <research@subreption.com>

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
 include/linux/highmem.h                |   12 ++++++++++++
 mm/page_alloc.c                        |   27 ++++++++++++++++++++++++++-
 24 files changed, 69 insertions(+), 9 deletions(-)

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
@@ -221,6 +222,15 @@ static inline int bad_range(struct zone 
 }
 #endif
 
+static __init int setup_page_sanitization(char *s)
+{
+	printk(KERN_INFO "Memory sanitization enabled.\n");
+	sanitize_all_mem = 1;
+
+	return 0;
+}
+early_param("sanitize_mem", setup_page_sanitization);
+
 static void bad_page(struct page *page)
 {
 	static unsigned long resume;
@@ -545,6 +555,7 @@ static void free_one_page(struct zone *z
 
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
+	unsigned long index = 1UL << order;
 	unsigned long flags;
 	int i;
 	int bad = 0;
@@ -559,6 +570,16 @@ static void __free_pages_ok(struct page 
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
 
@@ -647,7 +668,7 @@ static int prep_new_page(struct page *pa
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
 
-	if (gfp_flags & __GFP_ZERO)
+	if ((gfp_flags & __GFP_ZERO) && !sanitize_all_mem)
 		prep_zero_page(page, order, gfp_flags);
 
 	if (order && (gfp_flags & __GFP_COMP))
@@ -1009,6 +1030,10 @@ static void free_hot_cold_page(struct pa
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
 		debug_check_no_obj_freed(page_address(page), PAGE_SIZE);
 	}
+
+	if (sanitize_all_mem)
+		sanitize_highpage(page);
+
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
