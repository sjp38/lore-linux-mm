Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0ADC36B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 04:19:12 -0400 (EDT)
Subject: [PATCH 2/2] mm: remove kmap_atomic back-compatibility macro
From: Lin Ming <ming.m.lin@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 26 Aug 2011 16:19:09 +0800
Message-ID: <1314346749.6486.27.camel@minggr.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, peterz@infradead.org

Now nobody use the macro kmap_atomic(page, args...).
Remove it and convert __kmap_atomic to kmap_atomic.

Signed-off-by: Lin Ming <ming.m.lin@intel.com>
---
 arch/arm/mm/highmem.c                |    4 ++--
 arch/frv/include/asm/highmem.h       |    2 +-
 arch/frv/mm/highmem.c                |    4 ++--
 arch/mips/include/asm/highmem.h      |    2 +-
 arch/mips/mm/highmem.c               |    4 ++--
 arch/mn10300/include/asm/highmem.h   |    2 +-
 arch/parisc/include/asm/cacheflush.h |    2 +-
 arch/powerpc/include/asm/highmem.h   |    2 +-
 arch/sparc/include/asm/highmem.h     |    2 +-
 arch/sparc/mm/highmem.c              |    4 ++--
 arch/tile/include/asm/highmem.h      |    2 +-
 arch/tile/mm/highmem.c               |    4 ++--
 arch/x86/include/asm/highmem.h       |    2 +-
 arch/x86/mm/highmem_32.c             |    4 ++--
 include/linux/highmem.h              |    9 ++-------
 15 files changed, 22 insertions(+), 27 deletions(-)

diff --git a/arch/arm/mm/highmem.c b/arch/arm/mm/highmem.c
index 807c057..5a21505 100644
--- a/arch/arm/mm/highmem.c
+++ b/arch/arm/mm/highmem.c
@@ -36,7 +36,7 @@ void kunmap(struct page *page)
 }
 EXPORT_SYMBOL(kunmap);
 
-void *__kmap_atomic(struct page *page)
+void *kmap_atomic(struct page *page)
 {
 	unsigned int idx;
 	unsigned long vaddr;
@@ -81,7 +81,7 @@ void *__kmap_atomic(struct page *page)
 
 	return (void *)vaddr;
 }
-EXPORT_SYMBOL(__kmap_atomic);
+EXPORT_SYMBOL(kmap_atomic);
 
 void __kunmap_atomic(void *kvaddr)
 {
diff --git a/arch/frv/include/asm/highmem.h b/arch/frv/include/asm/highmem.h
index a8d6565..716956a 100644
--- a/arch/frv/include/asm/highmem.h
+++ b/arch/frv/include/asm/highmem.h
@@ -157,7 +157,7 @@ static inline void kunmap_atomic_primary(void *kvaddr, enum km_type type)
 	pagefault_enable();
 }
 
-void *__kmap_atomic(struct page *page);
+void *kmap_atomic(struct page *page);
 void __kunmap_atomic(void *kvaddr);
 
 #endif /* !__ASSEMBLY__ */
diff --git a/arch/frv/mm/highmem.c b/arch/frv/mm/highmem.c
index fd7fcd4..31902c9 100644
--- a/arch/frv/mm/highmem.c
+++ b/arch/frv/mm/highmem.c
@@ -37,7 +37,7 @@ struct page *kmap_atomic_to_page(void *ptr)
 	return virt_to_page(ptr);
 }
 
-void *__kmap_atomic(struct page *page)
+void *kmap_atomic(struct page *page)
 {
 	unsigned long paddr;
 	int type;
@@ -64,7 +64,7 @@ void *__kmap_atomic(struct page *page)
 		return NULL;
 	}
 }
-EXPORT_SYMBOL(__kmap_atomic);
+EXPORT_SYMBOL(kmap_atomic);
 
 void __kunmap_atomic(void *kvaddr)
 {
diff --git a/arch/mips/include/asm/highmem.h b/arch/mips/include/asm/highmem.h
index 77e6440..2d91888 100644
--- a/arch/mips/include/asm/highmem.h
+++ b/arch/mips/include/asm/highmem.h
@@ -47,7 +47,7 @@ extern void kunmap_high(struct page *page);
 
 extern void *kmap(struct page *page);
 extern void kunmap(struct page *page);
-extern void *__kmap_atomic(struct page *page);
+extern void *kmap_atomic(struct page *page);
 extern void __kunmap_atomic(void *kvaddr);
 extern void *kmap_atomic_pfn(unsigned long pfn);
 extern struct page *kmap_atomic_to_page(void *ptr);
diff --git a/arch/mips/mm/highmem.c b/arch/mips/mm/highmem.c
index 3634c7e..aff5705 100644
--- a/arch/mips/mm/highmem.c
+++ b/arch/mips/mm/highmem.c
@@ -41,7 +41,7 @@ EXPORT_SYMBOL(kunmap);
  * kmaps are appropriate for short, tight code paths only.
  */
 
-void *__kmap_atomic(struct page *page)
+void *kmap_atomic(struct page *page)
 {
 	unsigned long vaddr;
 	int idx, type;
@@ -62,7 +62,7 @@ void *__kmap_atomic(struct page *page)
 
 	return (void*) vaddr;
 }
-EXPORT_SYMBOL(__kmap_atomic);
+EXPORT_SYMBOL(kmap_atomic);
 
 void __kunmap_atomic(void *kvaddr)
 {
diff --git a/arch/mn10300/include/asm/highmem.h b/arch/mn10300/include/asm/highmem.h
index bfe2d88..7c137cd 100644
--- a/arch/mn10300/include/asm/highmem.h
+++ b/arch/mn10300/include/asm/highmem.h
@@ -70,7 +70,7 @@ static inline void kunmap(struct page *page)
  * be used in IRQ contexts, so in some (very limited) cases we need
  * it.
  */
-static inline unsigned long __kmap_atomic(struct page *page)
+static inline unsigned long kmap_atomic(struct page *page)
 {
 	unsigned long vaddr;
 	int idx, type;
diff --git a/arch/parisc/include/asm/cacheflush.h b/arch/parisc/include/asm/cacheflush.h
index da601dd..9f21ab0 100644
--- a/arch/parisc/include/asm/cacheflush.h
+++ b/arch/parisc/include/asm/cacheflush.h
@@ -140,7 +140,7 @@ static inline void *kmap(struct page *page)
 
 #define kunmap(page)			kunmap_parisc(page_address(page))
 
-static inline void *__kmap_atomic(struct page *page)
+static inline void *kmap_atomic(struct page *page)
 {
 	pagefault_disable();
 	return page_address(page);
diff --git a/arch/powerpc/include/asm/highmem.h b/arch/powerpc/include/asm/highmem.h
index dbc2640..caaf6e0 100644
--- a/arch/powerpc/include/asm/highmem.h
+++ b/arch/powerpc/include/asm/highmem.h
@@ -79,7 +79,7 @@ static inline void kunmap(struct page *page)
 	kunmap_high(page);
 }
 
-static inline void *__kmap_atomic(struct page *page)
+static inline void *kmap_atomic(struct page *page)
 {
 	return kmap_atomic_prot(page, kmap_prot);
 }
diff --git a/arch/sparc/include/asm/highmem.h b/arch/sparc/include/asm/highmem.h
index 3d7afbb..3b6e00d 100644
--- a/arch/sparc/include/asm/highmem.h
+++ b/arch/sparc/include/asm/highmem.h
@@ -70,7 +70,7 @@ static inline void kunmap(struct page *page)
 	kunmap_high(page);
 }
 
-extern void *__kmap_atomic(struct page *page);
+extern void *kmap_atomic(struct page *page);
 extern void __kunmap_atomic(void *kvaddr);
 extern struct page *kmap_atomic_to_page(void *vaddr);
 
diff --git a/arch/sparc/mm/highmem.c b/arch/sparc/mm/highmem.c
index 4730eac..58de5bb 100644
--- a/arch/sparc/mm/highmem.c
+++ b/arch/sparc/mm/highmem.c
@@ -29,7 +29,7 @@
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
 
-void *__kmap_atomic(struct page *page)
+void *kmap_atomic(struct page *page)
 {
 	unsigned long vaddr;
 	long idx, type;
@@ -63,7 +63,7 @@ void *__kmap_atomic(struct page *page)
 
 	return (void*) vaddr;
 }
-EXPORT_SYMBOL(__kmap_atomic);
+EXPORT_SYMBOL(kmap_atomic);
 
 void __kunmap_atomic(void *kvaddr)
 {
diff --git a/arch/tile/include/asm/highmem.h b/arch/tile/include/asm/highmem.h
index b2a6c5d..fc8429a 100644
--- a/arch/tile/include/asm/highmem.h
+++ b/arch/tile/include/asm/highmem.h
@@ -59,7 +59,7 @@ void *kmap_fix_kpte(struct page *page, int finished);
 /* This macro is used only in map_new_virtual() to map "page". */
 #define kmap_prot page_to_kpgprot(page)
 
-void *__kmap_atomic(struct page *page);
+void *kmap_atomic(struct page *page);
 void __kunmap_atomic(void *kvaddr);
 void *kmap_atomic_pfn(unsigned long pfn);
 void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
diff --git a/arch/tile/mm/highmem.c b/arch/tile/mm/highmem.c
index 31dbbd9..ef8e5a6 100644
--- a/arch/tile/mm/highmem.c
+++ b/arch/tile/mm/highmem.c
@@ -224,12 +224,12 @@ void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 }
 EXPORT_SYMBOL(kmap_atomic_prot);
 
-void *__kmap_atomic(struct page *page)
+void *kmap_atomic(struct page *page)
 {
 	/* PAGE_NONE is a magic value that tells us to check immutability. */
 	return kmap_atomic_prot(page, PAGE_NONE);
 }
-EXPORT_SYMBOL(__kmap_atomic);
+EXPORT_SYMBOL(kmap_atomic);
 
 void __kunmap_atomic(void *kvaddr)
 {
diff --git a/arch/x86/include/asm/highmem.h b/arch/x86/include/asm/highmem.h
index 3bd0402..302a323 100644
--- a/arch/x86/include/asm/highmem.h
+++ b/arch/x86/include/asm/highmem.h
@@ -61,7 +61,7 @@ void *kmap(struct page *page);
 void kunmap(struct page *page);
 
 void *kmap_atomic_prot(struct page *page, pgprot_t prot);
-void *__kmap_atomic(struct page *page);
+void *kmap_atomic(struct page *page);
 void __kunmap_atomic(void *kvaddr);
 void *kmap_atomic_pfn(unsigned long pfn);
 void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index b499626..9f85499 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -50,11 +50,11 @@ void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 }
 EXPORT_SYMBOL(kmap_atomic_prot);
 
-void *__kmap_atomic(struct page *page)
+void *kmap_atomic(struct page *page)
 {
 	return kmap_atomic_prot(page, kmap_prot);
 }
-EXPORT_SYMBOL(__kmap_atomic);
+EXPORT_SYMBOL(kmap_atomic);
 
 /*
  * This is the same as kmap_atomic() but can map memory that doesn't
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 8f129a6..b1fbd20 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -55,12 +55,12 @@ static inline void kunmap(struct page *page)
 {
 }
 
-static inline void *__kmap_atomic(struct page *page)
+static inline void *kmap_atomic(struct page *page)
 {
 	pagefault_disable();
 	return page_address(page);
 }
-#define kmap_atomic_prot(page, prot)	__kmap_atomic(page)
+#define kmap_atomic_prot(page, prot)	kmap_atomic(page)
 
 static inline void __kunmap_atomic(void *addr)
 {
@@ -109,11 +109,6 @@ static inline void kmap_atomic_idx_pop(void)
 #endif
 
 /*
- * Make both: kmap_atomic(page, idx) and kmap_atomic(page) work.
- */
-#define kmap_atomic(page, args...) __kmap_atomic(page)
-
-/*
  * Prevent people trying to call kunmap_atomic() as if it were kunmap()
  * kunmap_atomic() should get the return value of kmap_atomic, not the page.
  */
-- 
1.7.2.3



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
