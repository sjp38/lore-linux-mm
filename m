Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 44A536B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:30:13 -0400 (EDT)
Message-Id: <20100819202753.656285068@chello.nl>
Date: Thu, 19 Aug 2010 22:13:19 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 2/6] mm: stack based kmap_atomic
References: <20100819201317.673172547@chello.nl>
Content-Disposition: inline; filename=kmap-1.patch
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Keep the current interface but ignore the KM_type and use a stack
based approach.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/arm/mm/highmem.c              |    8 ++++
 arch/frv/include/asm/highmem.h     |    3 +
 arch/mips/mm/highmem.c             |   12 ++++---
 arch/mn10300/include/asm/highmem.h |   36 +++++++++++++--------
 arch/powerpc/mm/highmem.c          |   26 +++++++++------
 arch/sparc/mm/highmem.c            |   37 ++++++++++++----------
 arch/x86/mm/highmem_32.c           |   33 ++++++++++++-------
 arch/x86/mm/iomap_32.c             |   28 +++++++++++-----
 include/linux/highmem.h            |   32 +++++++++++--------
 mm/highmem.c                       |   62 ++-----------------------------------
 10 files changed, 139 insertions(+), 138 deletions(-)

Index: linux-2.6/arch/arm/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/highmem.c
+++ linux-2.6/arch/arm/mm/highmem.c
@@ -61,6 +61,8 @@ void *kmap_atomic(struct page *page, enu
 	if (kmap)
 		return kmap;
 
+	type = kmap_atomic_idx_push();
+
 	idx = type + KM_TYPE_NR * smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -85,9 +87,12 @@ EXPORT_SYMBOL(kmap_atomic);
 void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	unsigned int idx = type + KM_TYPE_NR * smp_processor_id();
+	unsigned int idx;
 
 	if (kvaddr >= (void *)FIXADDR_START) {
+		type = kmap_atomic_idx_pop();
+		idx = type + KM_TYPE_NR * smp_processor_id();
+
 		if (cache_is_vivt())
 			__cpuc_flush_dcache_area((void *)vaddr, PAGE_SIZE);
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -112,6 +117,7 @@ void *kmap_atomic_pfn(unsigned long pfn,
 
 	pagefault_disable();
 
+	type = kmap_atomic_idx_push();
 	idx = type + KM_TYPE_NR * smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
Index: linux-2.6/arch/frv/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/frv/include/asm/highmem.h
+++ linux-2.6/arch/frv/include/asm/highmem.h
@@ -117,7 +117,7 @@ static inline void *kmap_atomic(struct p
 	unsigned long paddr;
 
 	pagefault_disable();
-	debug_kmap_atomic(type);
+	type = kmap_atomic_idx_push();
 	paddr = page_to_phys(page);
 
 	switch (type) {
@@ -154,6 +154,7 @@ do {									\
 
 static inline void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
+	type = kmap_atomic_idx_pop();
 	switch (type) {
         case 0:		__kunmap_atomic_primary(0, 2);	break;
         case 1:		__kunmap_atomic_primary(1, 3);	break;
Index: linux-2.6/arch/mips/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/highmem.c
+++ linux-2.6/arch/mips/mm/highmem.c
@@ -51,7 +51,7 @@ void *__kmap_atomic(struct page *page, e
 	if (!PageHighMem(page))
 		return page_address(page);
 
-	debug_kmap_atomic(type);
+	type = kmap_atomic_idx_push();
 	idx = type + KM_TYPE_NR*smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -66,15 +66,18 @@ EXPORT_SYMBOL(__kmap_atomic);
 
 void __kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
-#ifdef CONFIG_DEBUG_HIGHMEM
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx = type + KM_TYPE_NR*smp_processor_id();
+	unsigned int idx;
 
 	if (vaddr < FIXADDR_START) { // FIXME
 		pagefault_enable();
 		return;
 	}
 
+	type = kmap_atomic_idx_pop();
+#ifdef CONFIG_DEBUG_HIGHMEM
+	idx = type + KM_TYPE_NR * smp_processor_id();
+
 	BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN + idx));
 
 	/*
@@ -84,7 +87,6 @@ void __kunmap_atomic_notypecheck(void *k
 	pte_clear(&init_mm, vaddr, kmap_pte-idx);
 	local_flush_tlb_one(vaddr);
 #endif
-
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic_notypecheck);
@@ -100,7 +102,7 @@ void *kmap_atomic_pfn(unsigned long pfn,
 
 	pagefault_disable();
 
-	debug_kmap_atomic(type);
+	type = kmap_atomic_idx_push();
 	idx = type + KM_TYPE_NR*smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 	set_pte(kmap_pte-idx, pfn_pte(pfn, PAGE_KERNEL));
Index: linux-2.6/arch/mn10300/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/mn10300/include/asm/highmem.h
+++ linux-2.6/arch/mn10300/include/asm/highmem.h
@@ -75,10 +75,11 @@ static inline unsigned long kmap_atomic(
 	enum fixed_addresses idx;
 	unsigned long vaddr;
 
+	pagefault_disable();
 	if (page < highmem_start_page)
 		return page_address(page);
 
-	debug_kmap_atomic(type);
+	type = kmap_atomic_idx_push();
 	idx = type + KM_TYPE_NR * smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #if HIGHMEM_DEBUG
@@ -93,24 +94,31 @@ static inline unsigned long kmap_atomic(
 
 static inline void kunmap_atomic_notypecheck(unsigned long vaddr, enum km_type type)
 {
-#if HIGHMEM_DEBUG
-	enum fixed_addresses idx = type + KM_TYPE_NR * smp_processor_id();
-
-	if (vaddr < FIXADDR_START) /* FIXME */
+	if (vaddr < FIXADDR_START) { /* FIXME */
+		pagefault_enable();
 		return;
+	}
 
-	if (vaddr != __fix_to_virt(FIX_KMAP_BEGIN + idx))
-		BUG();
+	type = kmap_atomic_idx_pop();
 
-	/*
-	 * force other mappings to Oops if they'll try to access
-	 * this pte without first remap it
-	 */
-	pte_clear(kmap_pte - idx);
-	__flush_tlb_one(vaddr);
+#if HIGHMEM_DEBUG
+	{
+		unsigned int idx;
+		idx = type + KM_TYPE_NR * smp_processor_id();
+
+		if (vaddr != __fix_to_virt(FIX_KMAP_BEGIN + idx))
+			BUG();
+
+		/*
+		 * force other mappings to Oops if they'll try to access
+		 * this pte without first remap it
+		 */
+		pte_clear(kmap_pte - idx);
+		__flush_tlb_one(vaddr);
+	}
 #endif
+	pagefault_enable();
 }
-
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_HIGHMEM_H */
Index: linux-2.6/arch/powerpc/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/highmem.c
+++ linux-2.6/arch/powerpc/mm/highmem.c
@@ -39,7 +39,7 @@ void *kmap_atomic_prot(struct page *page
 	if (!PageHighMem(page))
 		return page_address(page);
 
-	debug_kmap_atomic(type);
+	type = kmap_atomic_idx_push();
 	idx = type + KM_TYPE_NR*smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -54,23 +54,29 @@ EXPORT_SYMBOL(kmap_atomic_prot);
 
 void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
-#ifdef CONFIG_DEBUG_HIGHMEM
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx = type + KM_TYPE_NR*smp_processor_id();
 
 	if (vaddr < __fix_to_virt(FIX_KMAP_END)) {
 		pagefault_enable();
 		return;
 	}
 
-	BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN + idx));
+	type = kmap_atomic_idx_pop();
 
-	/*
-	 * force other mappings to Oops if they'll try to access
-	 * this pte without first remap it
-	 */
-	pte_clear(&init_mm, vaddr, kmap_pte-idx);
-	local_flush_tlb_page(NULL, vaddr);
+#ifdef CONFIG_DEBUG_HIGHMEM
+	{
+		unsigned int idx;
+
+		idx = type + KM_TYPE_NR * smp_processor_id();
+		BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN + idx));
+
+		/*
+		 * force other mappings to Oops if they'll try to access
+		 * this pte without first remap it
+		 */
+		pte_clear(&init_mm, vaddr, kmap_pte-idx);
+		local_flush_tlb_page(NULL, vaddr);
+	}
 #endif
 	pagefault_enable();
 }
Index: linux-2.6/arch/sparc/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/highmem.c
+++ linux-2.6/arch/sparc/mm/highmem.c
@@ -39,7 +39,7 @@ void *kmap_atomic(struct page *page, enu
 	if (!PageHighMem(page))
 		return page_address(page);
 
-	debug_kmap_atomic(type);
+	type = kmap_atomic_idx_push();
 	idx = type + KM_TYPE_NR*smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 
@@ -67,37 +67,42 @@ EXPORT_SYMBOL(kmap_atomic);
 
 void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
-#ifdef CONFIG_DEBUG_HIGHMEM
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	unsigned long idx = type + KM_TYPE_NR*smp_processor_id();
 
 	if (vaddr < FIXADDR_START) { // FIXME
 		pagefault_enable();
 		return;
 	}
 
-	BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN+idx));
+	type = kmap_atomic_idx_pop();
 
-/* XXX Fix - Anton */
+#ifdef CONFIG_DEBUG_HIGHMEM
+	{
+		unsigned long idx;
+
+		idx = type + KM_TYPE_NR * smp_processor_id();
+		BUG_ON(vaddr != __fix_to_virt(FIX_KMAP_BEGIN+idx));
+
+		/* XXX Fix - Anton */
 #if 0
-	__flush_cache_one(vaddr);
+		__flush_cache_one(vaddr);
 #else
-	flush_cache_all();
+		flush_cache_all();
 #endif
 
-	/*
-	 * force other mappings to Oops if they'll try to access
-	 * this pte without first remap it
-	 */
-	pte_clear(&init_mm, vaddr, kmap_pte-idx);
-/* XXX Fix - Anton */
+		/*
+		 * force other mappings to Oops if they'll try to access
+		 * this pte without first remap it
+		 */
+		pte_clear(&init_mm, vaddr, kmap_pte-idx);
+		/* XXX Fix - Anton */
 #if 0
-	__flush_tlb_one(vaddr);
+		__flush_tlb_one(vaddr);
 #else
-	flush_tlb_all();
+		flush_tlb_all();
 #endif
+	}
 #endif
-
 	pagefault_enable();
 }
 EXPORT_SYMBOL(kunmap_atomic_notypecheck);
Index: linux-2.6/arch/x86/mm/highmem_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/highmem_32.c
+++ linux-2.6/arch/x86/mm/highmem_32.c
@@ -38,8 +38,7 @@ void *kmap_atomic_prot(struct page *page
 	if (!PageHighMem(page))
 		return page_address(page);
 
-	debug_kmap_atomic(type);
-
+	type = kmap_atomic_idx_push();
 	idx = type + KM_TYPE_NR*smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 	BUG_ON(!pte_none(*(kmap_pte-idx)));
@@ -56,22 +55,32 @@ void *kmap_atomic(struct page *page, enu
 void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx = type + KM_TYPE_NR*smp_processor_id();
+	enum fixed_addresses idx;
+
+	if (vaddr >= __fix_to_virt(FIX_KMAP_END) &&
+	    vaddr <= __fix_to_virt(FIX_KMAP_BEGIN)) {
+
+		type = kmap_atomic_idx_pop();
+		idx = type + KM_TYPE_NR * smp_processor_id();
 
-	/*
-	 * Force other mappings to Oops if they'll try to access this pte
-	 * without first remap it.  Keeping stale mappings around is a bad idea
-	 * also, in case the page changes cacheability attributes or becomes
-	 * a protected page in a hypervisor.
-	 */
-	if (vaddr == __fix_to_virt(FIX_KMAP_BEGIN+idx))
+#ifdef CONFIG_DEBUG_HIGHMEM
+		WARN_ON_ONCE(idx !=
+			((vaddr - __fix_to_virt(FIX_KMAP_BEGIN)) >> PAGE_SHIFT));
+#endif
+		/*
+		 * Force other mappings to Oops if they'll try to access this
+		 * pte without first remap it.  Keeping stale mappings around
+		 * is a bad idea also, in case the page changes cacheability
+		 * attributes or becomes a protected page in a hypervisor.
+		 */
 		kpte_clear_flush(kmap_pte-idx, vaddr);
-	else {
+	}
 #ifdef CONFIG_DEBUG_HIGHMEM
+	else {
 		BUG_ON(vaddr < PAGE_OFFSET);
 		BUG_ON(vaddr >= (unsigned long)high_memory);
-#endif
 	}
+#endif
 
 	pagefault_enable();
 }
Index: linux-2.6/include/linux/highmem.h
===================================================================
--- linux-2.6.orig/include/linux/highmem.h
+++ linux-2.6/include/linux/highmem.h
@@ -28,18 +28,6 @@ static inline void invalidate_kernel_vma
 
 #include <asm/kmap_types.h>
 
-#ifdef CONFIG_DEBUG_HIGHMEM
-
-void debug_kmap_atomic(enum km_type type);
-
-#else
-
-static inline void debug_kmap_atomic(enum km_type type)
-{
-}
-
-#endif
-
 #ifdef CONFIG_HIGHMEM
 #include <asm/highmem.h>
 
@@ -49,6 +37,26 @@ extern unsigned long totalhigh_pages;
 
 void kmap_flush_unused(void);
 
+DECLARE_PER_CPU(int, __kmap_atomic_idx);
+
+static inline int kmap_atomic_idx_push(void)
+{
+	int idx = __get_cpu_var(__kmap_atomic_idx)++;
+#ifdef CONFIG_DEBUG_HIGHMEM
+	BUG_ON(idx > KM_TYPE_NR);
+#endif
+	return idx;
+}
+
+static inline int kmap_atomic_idx_pop(void)
+{
+	int idx = --__get_cpu_var(__kmap_atomic_idx);
+#ifdef CONFIG_DEBUG_HIGHMEM
+	BUG_ON(idx < 0);
+#endif
+	return idx;
+}
+
 #else /* CONFIG_HIGHMEM */
 
 static inline unsigned int nr_free_highpages(void) { return 0; }
Index: linux-2.6/mm/highmem.c
===================================================================
--- linux-2.6.orig/mm/highmem.c
+++ linux-2.6/mm/highmem.c
@@ -42,6 +42,10 @@
 unsigned long totalhigh_pages __read_mostly;
 EXPORT_SYMBOL(totalhigh_pages);
 
+
+DEFINE_PER_CPU(int, __kmap_atomic_idx);
+EXPORT_PER_CPU_SYMBOL_GPL(__kmap_atomic_idx);
+
 unsigned int nr_free_highpages (void)
 {
 	pg_data_t *pgdat;
@@ -422,61 +426,3 @@ void __init page_address_init(void)
 }
 
 #endif	/* defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL) */
-
-#ifdef CONFIG_DEBUG_HIGHMEM
-
-void debug_kmap_atomic(enum km_type type)
-{
-	static int warn_count = 10;
-
-	if (unlikely(warn_count < 0))
-		return;
-
-	if (unlikely(in_interrupt())) {
-		if (in_nmi()) {
-			if (type != KM_NMI && type != KM_NMI_PTE) {
-				WARN_ON(1);
-				warn_count--;
-			}
-		} else if (in_irq()) {
-			if (type != KM_IRQ0 && type != KM_IRQ1 &&
-			    type != KM_BIO_SRC_IRQ && type != KM_BIO_DST_IRQ &&
-			    type != KM_BOUNCE_READ && type != KM_IRQ_PTE) {
-				WARN_ON(1);
-				warn_count--;
-			}
-		} else if (!irqs_disabled()) {	/* softirq */
-			if (type != KM_IRQ0 && type != KM_IRQ1 &&
-			    type != KM_SOFTIRQ0 && type != KM_SOFTIRQ1 &&
-			    type != KM_SKB_SUNRPC_DATA &&
-			    type != KM_SKB_DATA_SOFTIRQ &&
-			    type != KM_BOUNCE_READ) {
-				WARN_ON(1);
-				warn_count--;
-			}
-		}
-	}
-
-	if (type == KM_IRQ0 || type == KM_IRQ1 || type == KM_BOUNCE_READ ||
-			type == KM_BIO_SRC_IRQ || type == KM_BIO_DST_IRQ ||
-			type == KM_IRQ_PTE || type == KM_NMI ||
-			type == KM_NMI_PTE ) {
-		if (!irqs_disabled()) {
-			WARN_ON(1);
-			warn_count--;
-		}
-	} else if (type == KM_SOFTIRQ0 || type == KM_SOFTIRQ1) {
-		if (irq_count() == 0 && !irqs_disabled()) {
-			WARN_ON(1);
-			warn_count--;
-		}
-	}
-#ifdef CONFIG_KGDB_KDB
-	if (unlikely(type == KM_KDB && atomic_read(&kgdb_active) == -1)) {
-		WARN_ON(1);
-		warn_count--;
-	}
-#endif /* CONFIG_KGDB_KDB */
-}
-
-#endif
Index: linux-2.6/arch/x86/mm/iomap_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/iomap_32.c
+++ linux-2.6/arch/x86/mm/iomap_32.c
@@ -62,7 +62,7 @@ void *kmap_atomic_prot_pfn(unsigned long
 
 	pagefault_disable();
 
-	debug_kmap_atomic(type);
+	type = kmap_atomic_idx_push();
 	idx = type + KM_TYPE_NR * smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 	set_pte(kmap_pte - idx, pfn_pte(pfn, prot));
@@ -94,16 +94,26 @@ void
 iounmap_atomic(void *kvaddr, enum km_type type)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx = type + KM_TYPE_NR*smp_processor_id();
+	enum fixed_addresses idx;
 
-	/*
-	 * Force other mappings to Oops if they'll try to access this pte
-	 * without first remap it.  Keeping stale mappings around is a bad idea
-	 * also, in case the page changes cacheability attributes or becomes
-	 * a protected page in a hypervisor.
-	 */
-	if (vaddr == __fix_to_virt(FIX_KMAP_BEGIN+idx))
+	if (vaddr >= __fix_to_virt(FIX_KMAP_END) &&
+	    vaddr <= __fix_to_virt(FIX_KMAP_BEGIN)) {
+
+		type = kmap_atomic_idx_pop();
+		idx = type + KM_TYPE_NR * smp_processor_id();
+
+#ifdef CONFIG_DEBUG_HIGHMEM
+		WARN_ON_ONCE(idx !=
+			((vaddr - __fix_to_virt(FIX_KMAP_BEGIN)) >> PAGE_SHIFT));
+#endif
+		/*
+		 * Force other mappings to Oops if they'll try to access this
+		 * pte without first remap it.  Keeping stale mappings around
+		 * is a bad idea also, in case the page changes cacheability
+		 * attributes or becomes a protected page in a hypervisor.
+		 */
 		kpte_clear_flush(kmap_pte-idx, vaddr);
+	}
 
 	pagefault_enable();
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
