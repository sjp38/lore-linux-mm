Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 08EB16B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 16:45:50 -0400 (EDT)
Received: by qkht68 with SMTP id t68so10968175qkh.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 13:45:49 -0700 (PDT)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com. [209.85.220.169])
        by mx.google.com with ESMTPS id k64si35694851qhk.111.2015.10.07.13.45.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 13:45:49 -0700 (PDT)
Received: by qkap81 with SMTP id p81so10990132qka.2
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 13:45:49 -0700 (PDT)
Date: Wed, 7 Oct 2015 16:45:47 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH] kmap_atomic_to_page() has no users, remove it
Message-ID: <alpine.LFD.2.20.1510071638110.1531@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


Removal started in commit 5bbeed12bdc3.  Let's do it across the whole tree.

Signed-off-by: Nicolas Pitre <nico@linaro.org>

diff --git a/arch/arm/include/asm/highmem.h b/arch/arm/include/asm/highmem.h
index 535579511e..0a0e2d1784 100644
--- a/arch/arm/include/asm/highmem.h
+++ b/arch/arm/include/asm/highmem.h
@@ -68,7 +68,6 @@ extern void kunmap(struct page *page);
 extern void *kmap_atomic(struct page *page);
 extern void __kunmap_atomic(void *kvaddr);
 extern void *kmap_atomic_pfn(unsigned long pfn);
-extern struct page *kmap_atomic_to_page(const void *ptr);
 #endif
 
 #endif
diff --git a/arch/arm/mm/highmem.c b/arch/arm/mm/highmem.c
index 9df5f09585..d02f8187b1 100644
--- a/arch/arm/mm/highmem.c
+++ b/arch/arm/mm/highmem.c
@@ -147,13 +147,3 @@ void *kmap_atomic_pfn(unsigned long pfn)
 
 	return (void *)vaddr;
 }
-
-struct page *kmap_atomic_to_page(const void *ptr)
-{
-	unsigned long vaddr = (unsigned long)ptr;
-
-	if (vaddr < FIXADDR_START)
-		return virt_to_page(ptr);
-
-	return pte_page(get_fixmap_pte(vaddr));
-}
diff --git a/arch/frv/include/asm/highmem.h b/arch/frv/include/asm/highmem.h
index b3adc93611..1f58938703 100644
--- a/arch/frv/include/asm/highmem.h
+++ b/arch/frv/include/asm/highmem.h
@@ -62,8 +62,6 @@ extern void kunmap_high(struct page *page);
 extern void *kmap(struct page *page);
 extern void kunmap(struct page *page);
 
-extern struct page *kmap_atomic_to_page(void *ptr);
-
 #endif /* !__ASSEMBLY__ */
 
 /*
diff --git a/arch/frv/mm/highmem.c b/arch/frv/mm/highmem.c
index 785344bbdc..45750fb65c 100644
--- a/arch/frv/mm/highmem.c
+++ b/arch/frv/mm/highmem.c
@@ -32,11 +32,6 @@ void kunmap(struct page *page)
 
 EXPORT_SYMBOL(kunmap);
 
-struct page *kmap_atomic_to_page(void *ptr)
-{
-	return virt_to_page(ptr);
-}
-
 void *kmap_atomic(struct page *page)
 {
 	unsigned long paddr;
diff --git a/arch/metag/include/asm/highmem.h b/arch/metag/include/asm/highmem.h
index 6646a15c73..9b1d172cd8 100644
--- a/arch/metag/include/asm/highmem.h
+++ b/arch/metag/include/asm/highmem.h
@@ -56,7 +56,6 @@ extern void kunmap(struct page *page);
 extern void *kmap_atomic(struct page *page);
 extern void __kunmap_atomic(void *kvaddr);
 extern void *kmap_atomic_pfn(unsigned long pfn);
-extern struct page *kmap_atomic_to_page(void *ptr);
 #endif
 
 #endif
diff --git a/arch/metag/mm/highmem.c b/arch/metag/mm/highmem.c
index 807f1b1c4e..f19a87f2c1 100644
--- a/arch/metag/mm/highmem.c
+++ b/arch/metag/mm/highmem.c
@@ -111,20 +111,6 @@ void *kmap_atomic_pfn(unsigned long pfn)
 	return (void *)vaddr;
 }
 
-struct page *kmap_atomic_to_page(void *ptr)
-{
-	unsigned long vaddr = (unsigned long)ptr;
-	int idx;
-	pte_t *pte;
-
-	if (vaddr < FIXADDR_START)
-		return virt_to_page(ptr);
-
-	idx = virt_to_fix(vaddr);
-	pte = kmap_pte - (idx - FIX_KMAP_BEGIN);
-	return pte_page(*pte);
-}
-
 void __init kmap_init(void)
 {
 	unsigned long kmap_vstart;
diff --git a/arch/microblaze/include/asm/highmem.h b/arch/microblaze/include/asm/highmem.h
index d046389324..67925ef18c 100644
--- a/arch/microblaze/include/asm/highmem.h
+++ b/arch/microblaze/include/asm/highmem.h
@@ -76,19 +76,6 @@ static inline void *kmap_atomic(struct page *page)
 	return kmap_atomic_prot(page, kmap_prot);
 }
 
-static inline struct page *kmap_atomic_to_page(void *ptr)
-{
-	unsigned long idx, vaddr = (unsigned long) ptr;
-	pte_t *pte;
-
-	if (vaddr < FIXADDR_START)
-		return virt_to_page(ptr);
-
-	idx = virt_to_fix(vaddr);
-	pte = kmap_pte - (idx - FIX_KMAP_BEGIN);
-	return pte_page(*pte);
-}
-
 #define flush_cache_kmaps()	{ flush_icache(); flush_dcache(); }
 
 #endif /* __KERNEL__ */
diff --git a/arch/mips/include/asm/highmem.h b/arch/mips/include/asm/highmem.h
index 572e63ec2a..01880b34a2 100644
--- a/arch/mips/include/asm/highmem.h
+++ b/arch/mips/include/asm/highmem.h
@@ -49,7 +49,6 @@ extern void kunmap(struct page *page);
 extern void *kmap_atomic(struct page *page);
 extern void __kunmap_atomic(void *kvaddr);
 extern void *kmap_atomic_pfn(unsigned long pfn);
-extern struct page *kmap_atomic_to_page(void *ptr);
 
 #define flush_cache_kmaps()	flush_cache_all()
 
diff --git a/arch/mips/mm/highmem.c b/arch/mips/mm/highmem.c
index 11661cbc11..d7258a1034 100644
--- a/arch/mips/mm/highmem.c
+++ b/arch/mips/mm/highmem.c
@@ -118,19 +118,6 @@ void *kmap_atomic_pfn(unsigned long pfn)
 	return (void*) vaddr;
 }
 
-struct page *kmap_atomic_to_page(void *ptr)
-{
-	unsigned long idx, vaddr = (unsigned long)ptr;
-	pte_t *pte;
-
-	if (vaddr < FIXADDR_START)
-		return virt_to_page(ptr);
-
-	idx = virt_to_fix(vaddr);
-	pte = kmap_pte - (idx - FIX_KMAP_BEGIN);
-	return pte_page(*pte);
-}
-
 void __init kmap_init(void)
 {
 	unsigned long kmap_vstart;
diff --git a/arch/parisc/include/asm/cacheflush.h b/arch/parisc/include/asm/cacheflush.h
index ec2df4bab3..845272ce9c 100644
--- a/arch/parisc/include/asm/cacheflush.h
+++ b/arch/parisc/include/asm/cacheflush.h
@@ -156,7 +156,6 @@ static inline void __kunmap_atomic(void *addr)
 
 #define kmap_atomic_prot(page, prot)	kmap_atomic(page)
 #define kmap_atomic_pfn(pfn)	kmap_atomic(pfn_to_page(pfn))
-#define kmap_atomic_to_page(ptr)	virt_to_page(ptr)
 
 #endif /* _PARISC_CACHEFLUSH_H */
 
diff --git a/arch/powerpc/include/asm/highmem.h b/arch/powerpc/include/asm/highmem.h
index caaf6e0063..01c2c23b30 100644
--- a/arch/powerpc/include/asm/highmem.h
+++ b/arch/powerpc/include/asm/highmem.h
@@ -84,19 +84,6 @@ static inline void *kmap_atomic(struct page *page)
 	return kmap_atomic_prot(page, kmap_prot);
 }
 
-static inline struct page *kmap_atomic_to_page(void *ptr)
-{
-	unsigned long idx, vaddr = (unsigned long) ptr;
-	pte_t *pte;
-
-	if (vaddr < FIXADDR_START)
-		return virt_to_page(ptr);
-
-	idx = virt_to_fix(vaddr);
-	pte = kmap_pte - (idx - FIX_KMAP_BEGIN);
-	return pte_page(*pte);
-}
-
 
 #define flush_cache_kmaps()	flush_cache_all()
 
diff --git a/arch/tile/include/asm/highmem.h b/arch/tile/include/asm/highmem.h
index fc8429a31c..979579b38e 100644
--- a/arch/tile/include/asm/highmem.h
+++ b/arch/tile/include/asm/highmem.h
@@ -63,7 +63,6 @@ void *kmap_atomic(struct page *page);
 void __kunmap_atomic(void *kvaddr);
 void *kmap_atomic_pfn(unsigned long pfn);
 void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
-struct page *kmap_atomic_to_page(void *ptr);
 void *kmap_atomic_prot(struct page *page, pgprot_t prot);
 void kmap_atomic_fix_kpte(struct page *page, int finished);
 
diff --git a/arch/tile/mm/highmem.c b/arch/tile/mm/highmem.c
index fcd545014e..eca28551b2 100644
--- a/arch/tile/mm/highmem.c
+++ b/arch/tile/mm/highmem.c
@@ -275,15 +275,3 @@ void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 {
 	return kmap_atomic_prot(pfn_to_page(pfn), prot);
 }
-
-struct page *kmap_atomic_to_page(void *ptr)
-{
-	pte_t *pte;
-	unsigned long vaddr = (unsigned long)ptr;
-
-	if (vaddr < FIXADDR_START)
-		return virt_to_page(ptr);
-
-	pte = kmap_get_pte(vaddr);
-	return pte_page(*pte);
-}
diff --git a/arch/x86/include/asm/highmem.h b/arch/x86/include/asm/highmem.h
index 04e9d02316..1c0b43724c 100644
--- a/arch/x86/include/asm/highmem.h
+++ b/arch/x86/include/asm/highmem.h
@@ -68,7 +68,6 @@ void *kmap_atomic(struct page *page);
 void __kunmap_atomic(void *kvaddr);
 void *kmap_atomic_pfn(unsigned long pfn);
 void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
-struct page *kmap_atomic_to_page(void *ptr);
 
 #define flush_cache_kmaps()	do { } while (0)
 
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index eecb207a20..a6d7392581 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -104,20 +104,6 @@ void __kunmap_atomic(void *kvaddr)
 }
 EXPORT_SYMBOL(__kunmap_atomic);
 
-struct page *kmap_atomic_to_page(void *ptr)
-{
-	unsigned long idx, vaddr = (unsigned long)ptr;
-	pte_t *pte;
-
-	if (vaddr < FIXADDR_START)
-		return virt_to_page(ptr);
-
-	idx = virt_to_fix(vaddr);
-	pte = kmap_pte - (idx - FIX_KMAP_BEGIN);
-	return pte_page(*pte);
-}
-EXPORT_SYMBOL(kmap_atomic_to_page);
-
 void __init set_highmem_pages_init(void)
 {
 	struct zone *zone;
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 6aefcd0031..bb3f329706 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -78,7 +78,6 @@ static inline void __kunmap_atomic(void *addr)
 }
 
 #define kmap_atomic_pfn(pfn)	kmap_atomic(pfn_to_page(pfn))
-#define kmap_atomic_to_page(ptr)	virt_to_page(ptr)
 
 #define kmap_flush_unused()	do {} while(0)
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
