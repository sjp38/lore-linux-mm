Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9695E6B01FF
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:30:43 -0400 (EDT)
Message-Id: <20100819202753.710621383@chello.nl>
Date: Thu, 19 Aug 2010 22:13:20 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 3/6] mm, frv: Out-of-line kmap-atomic
References: <20100819201317.673172547@chello.nl>
Content-Disposition: inline; filename=kmap-frv.patch
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Out-of-line the kmap_atomic implementation since the dynamic type
destroys all the constant value reduction previously used.

Also, remove the first 4 primary maps, since those are used by the
architecture for special purposes, mostly through direct assembly, but
also through the __kmap_atomic_primary() interface.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/frv/include/asm/highmem.h  |   53 +---------------------------------------
 arch/frv/mb93090-mb00/pci-dma.c |    4 +--
 arch/frv/mm/cache-page.c        |    8 +++---
 arch/frv/mm/highmem.c           |   50 +++++++++++++++++++++++++++++++++++++
 4 files changed, 58 insertions(+), 57 deletions(-)

Index: linux-2.6/arch/frv/include/asm/highmem.h
===================================================================
--- linux-2.6.orig/arch/frv/include/asm/highmem.h
+++ linux-2.6/arch/frv/include/asm/highmem.h
@@ -112,34 +112,6 @@ extern struct page *kmap_atomic_to_page(
 	(void *) damlr;										  \
 })
 
-static inline void *kmap_atomic(struct page *page, enum km_type type)
-{
-	unsigned long paddr;
-
-	pagefault_disable();
-	type = kmap_atomic_idx_push();
-	paddr = page_to_phys(page);
-
-	switch (type) {
-        case 0:		return __kmap_atomic_primary(0, paddr, 2);
-        case 1:		return __kmap_atomic_primary(1, paddr, 3);
-        case 2:		return __kmap_atomic_primary(2, paddr, 4);
-        case 3:		return __kmap_atomic_primary(3, paddr, 5);
-        case 4:		return __kmap_atomic_primary(4, paddr, 6);
-        case 5:		return __kmap_atomic_primary(5, paddr, 7);
-        case 6:		return __kmap_atomic_primary(6, paddr, 8);
-        case 7:		return __kmap_atomic_primary(7, paddr, 9);
-        case 8:		return __kmap_atomic_primary(8, paddr, 10);
-
-	case 9 ... 9 + NR_TLB_LINES - 1:
-		return __kmap_atomic_secondary(type - 9, paddr);
-
-	default:
-		BUG();
-		return NULL;
-	}
-}
-
 #define __kunmap_atomic_primary(type, ampr)				\
 do {									\
 	asm volatile("movgs gr0,dampr"#ampr"\n" ::: "memory");		\
@@ -152,29 +124,8 @@ do {									\
 	asm volatile("tlbpr %0,gr0,#4,#1" : : "r"(vaddr) : "memory");	\
 } while(0)
 
-static inline void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
-{
-	type = kmap_atomic_idx_pop();
-	switch (type) {
-        case 0:		__kunmap_atomic_primary(0, 2);	break;
-        case 1:		__kunmap_atomic_primary(1, 3);	break;
-        case 2:		__kunmap_atomic_primary(2, 4);	break;
-        case 3:		__kunmap_atomic_primary(3, 5);	break;
-        case 4:		__kunmap_atomic_primary(4, 6);	break;
-        case 5:		__kunmap_atomic_primary(5, 7);	break;
-        case 6:		__kunmap_atomic_primary(6, 8);	break;
-        case 7:		__kunmap_atomic_primary(7, 9);	break;
-        case 8:		__kunmap_atomic_primary(8, 10);	break;
-
-	case 9 ... 9 + NR_TLB_LINES - 1:
-		__kunmap_atomic_secondary(type - 9, kvaddr);
-		break;
-
-	default:
-		BUG();
-	}
-	pagefault_enable();
-}
+void *kmap_atomic(struct page *page, enum km_type type);
+void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
 
 #endif /* !__ASSEMBLY__ */
 
Index: linux-2.6/arch/frv/mm/cache-page.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/cache-page.c
+++ linux-2.6/arch/frv/mm/cache-page.c
@@ -26,11 +26,11 @@ void flush_dcache_page(struct page *page
 
 	dampr2 = __get_DAMPR(2);
 
-	vaddr = kmap_atomic(page, __KM_CACHE);
+	vaddr = __kmap_atomic_primary(0, page, 2);
 
 	frv_dcache_writeback((unsigned long) vaddr, (unsigned long) vaddr + PAGE_SIZE);
 
-	kunmap_atomic(vaddr, __KM_CACHE);
+	__kunmap_atomic_primary(0, 2);
 
 	if (dampr2) {
 		__set_DAMPR(2, dampr2);
@@ -54,12 +54,12 @@ void flush_icache_user_range(struct vm_a
 
 	dampr2 = __get_DAMPR(2);
 
-	vaddr = kmap_atomic(page, __KM_CACHE);
+	vaddr = __kmap_atomic_primary(0, page, 2);
 
 	start = (start & ~PAGE_MASK) | (unsigned long) vaddr;
 	frv_cache_wback_inv(start, start + len);
 
-	kunmap_atomic(vaddr, __KM_CACHE);
+	__kunmap_atomic_primary(0, 2);
 
 	if (dampr2) {
 		__set_DAMPR(2, dampr2);
Index: linux-2.6/arch/frv/mm/highmem.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/highmem.c
+++ linux-2.6/arch/frv/mm/highmem.c
@@ -36,3 +36,53 @@ struct page *kmap_atomic_to_page(void *p
 {
 	return virt_to_page(ptr);
 }
+
+void *kmap_atomic(struct page *page, enum km_type type)
+{
+	unsigned long paddr;
+
+	pagefault_disable();
+	type = kmap_atomic_idx_push();
+	paddr = page_to_phys(page);
+
+	switch (type) {
+	/*
+	 * The first 4 primary maps are reserved for architecture code
+	 */
+        case 0:		return __kmap_atomic_primary(4, paddr, 6);
+        case 1:		return __kmap_atomic_primary(5, paddr, 7);
+        case 2:		return __kmap_atomic_primary(6, paddr, 8);
+        case 3:		return __kmap_atomic_primary(7, paddr, 9);
+        case 4:		return __kmap_atomic_primary(8, paddr, 10);
+
+	case 5 ... 5 + NR_TLB_LINES - 1:
+		return __kmap_atomic_secondary(type - 5, paddr);
+
+	default:
+		BUG();
+		return NULL;
+	}
+}
+EXPORT_SYMBOL(kmap_atomic);
+
+void kunmap_atomic(void *kvaddr, enum km_type type)
+{
+	type = kmap_atomic_idx_pop();
+	switch (type) {
+        case 0:		__kunmap_atomic_primary(4, 6);	break;
+        case 1:		__kunmap_atomic_primary(5, 7);	break;
+        case 2:		__kunmap_atomic_primary(6, 8);	break;
+        case 3:		__kunmap_atomic_primary(7, 9);	break;
+        case 4:		__kunmap_atomic_primary(8, 10);	break;
+
+	case 5 ... 5 + NR_TLB_LINES - 1:
+		__kunmap_atomic_secondary(type - 5, kvaddr);
+		break;
+
+	default:
+		BUG();
+	}
+	pagefault_enable();
+}
+EXPORT_SYMBOL(kunmap_atomic);
+
Index: linux-2.6/arch/frv/mb93090-mb00/pci-dma.c
===================================================================
--- linux-2.6.orig/arch/frv/mb93090-mb00/pci-dma.c
+++ linux-2.6/arch/frv/mb93090-mb00/pci-dma.c
@@ -61,14 +61,14 @@ int dma_map_sg(struct device *dev, struc
 	dampr2 = __get_DAMPR(2);
 
 	for (i = 0; i < nents; i++) {
-		vaddr = kmap_atomic(sg_page(&sg[i]), __KM_CACHE);
+		vaddr = __kmap_atomic_primary(0, sg_page(&sg[i]), 2);
 
 		frv_dcache_writeback((unsigned long) vaddr,
 				     (unsigned long) vaddr + PAGE_SIZE);
 
 	}
 
-	kunmap_atomic(vaddr, __KM_CACHE);
+	__kunmap_atomic_primary(0, 2);
 	if (dampr2) {
 		__set_DAMPR(2, dampr2);
 		__set_IAMPR(2, dampr2);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
