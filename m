Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6DC6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 06:45:33 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o8SAjSod030666
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 03:45:29 -0700
Received: from pvb32 (pvb32.prod.google.com [10.241.209.96])
	by wpaz5.hot.corp.google.com with ESMTP id o8SAj7SQ007777
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 03:45:27 -0700
Received: by pvb32 with SMTP id 32so2533849pvb.15
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 03:45:26 -0700 (PDT)
Date: Tue, 28 Sep 2010 03:45:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] arch: remove __GFP_REPEAT for order-0 allocations
Message-ID: <alpine.DEB.2.00.1009280344280.11433@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Russell King <linux@arm.linux.org.uk>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, David Howells <dhowells@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Order-0 allocations, including quicklist_alloc(),  are always under 
PAGE_ALLOC_COSTLY_ORDER, so they loop endlessly in the page allocator
already without the need for __GFP_REPEAT.

Also includes general cleanups to convert alloc_pages(gfp_mask, 0) to its
equivalent alloc_page(gfp_mask).

Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/alpha/include/asm/pgalloc.h         |    4 ++--
 arch/arm/include/asm/pgalloc.h           |    2 +-
 arch/avr32/include/asm/pgalloc.h         |    6 +++---
 arch/cris/include/asm/pgalloc.h          |    4 ++--
 arch/frv/mm/pgalloc.c                    |    6 +++---
 arch/m68k/include/asm/motorola_pgalloc.h |    4 ++--
 arch/m68k/include/asm/sun3_pgalloc.h     |    4 ++--
 arch/microblaze/include/asm/pgalloc.h    |    7 +++----
 arch/microblaze/mm/pgtable.c             |    3 +--
 arch/mn10300/mm/pgtable.c                |    6 +++---
 arch/parisc/include/asm/pgalloc.h        |    4 ++--
 arch/powerpc/include/asm/pgalloc-64.h    |    2 +-
 arch/powerpc/mm/pgtable_32.c             |    6 ++----
 arch/s390/mm/pgtable.c                   |    2 +-
 arch/sh/include/asm/pgalloc.h            |    4 ++--
 arch/sparc/mm/sun4c.c                    |    2 +-
 arch/um/kernel/mem.c                     |    4 ++--
 arch/x86/include/asm/pgalloc.h           |    4 ++--
 arch/x86/mm/pgtable.c                    |    2 +-
 19 files changed, 36 insertions(+), 40 deletions(-)

diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pgalloc.h
--- a/arch/alpha/include/asm/pgalloc.h
+++ b/arch/alpha/include/asm/pgalloc.h
@@ -40,7 +40,7 @@ pgd_free(struct mm_struct *mm, pgd_t *pgd)
 static inline pmd_t *
 pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	pmd_t *ret = (pmd_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pmd_t *ret = (pmd_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	return ret;
 }
 
@@ -53,7 +53,7 @@ pmd_free(struct mm_struct *mm, pmd_t *pmd)
 static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	return pte;
 }
 
diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -36,7 +36,7 @@ extern void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd);
 #define pgd_alloc(mm)			get_pgd_slow(mm)
 #define pgd_free(mm, pgd)		free_pgd_slow(mm, pgd)
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
+#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
 
 /*
  * Allocate one PTE table.
diff --git a/arch/avr32/include/asm/pgalloc.h b/arch/avr32/include/asm/pgalloc.h
--- a/arch/avr32/include/asm/pgalloc.h
+++ b/arch/avr32/include/asm/pgalloc.h
@@ -42,7 +42,7 @@ static inline void pgd_ctor(void *x)
  */
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return quicklist_alloc(QUICK_PGD, GFP_KERNEL | __GFP_REPEAT, pgd_ctor);
+	return quicklist_alloc(QUICK_PGD, GFP_KERNEL, pgd_ctor);
 }
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
@@ -53,7 +53,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	return quicklist_alloc(QUICK_PT, GFP_KERNEL, NULL);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
@@ -62,7 +62,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 	struct page *page;
 	void *pg;
 
-	pg = quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	pg = quicklist_alloc(QUICK_PT, GFP_KERNEL, NULL);
 	if (!pg)
 		return NULL;
 
diff --git a/arch/cris/include/asm/pgalloc.h b/arch/cris/include/asm/pgalloc.h
--- a/arch/cris/include/asm/pgalloc.h
+++ b/arch/cris/include/asm/pgalloc.h
@@ -24,14 +24,14 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-  	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+  	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
  	return pte;
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
-	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	pte = alloc_page(GFP_KERNEL|__GFP_ZERO);
 	pgtable_page_ctor(pte);
 	return pte;
 }
diff --git a/arch/frv/mm/pgalloc.c b/arch/frv/mm/pgalloc.c
--- a/arch/frv/mm/pgalloc.c
+++ b/arch/frv/mm/pgalloc.c
@@ -22,7 +22,7 @@ pgd_t swapper_pg_dir[PTRS_PER_PGD] __attribute__((aligned(PAGE_SIZE)));
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL);
 	if (pte)
 		clear_page(pte);
 	return pte;
@@ -33,9 +33,9 @@ pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 	struct page *page;
 
 #ifdef CONFIG_HIGHPTE
-	page = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT, 0);
+	page = alloc_page(GFP_KERNEL|__GFP_HIGHMEM);
 #else
-	page = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
+	page = alloc_page(GFP_KERNEL);
 #endif
 	if (page) {
 		clear_highpage(page);
diff --git a/arch/m68k/include/asm/motorola_pgalloc.h b/arch/m68k/include/asm/motorola_pgalloc.h
--- a/arch/m68k/include/asm/motorola_pgalloc.h
+++ b/arch/m68k/include/asm/motorola_pgalloc.h
@@ -11,7 +11,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long ad
 {
 	pte_t *pte;
 
-	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	if (pte) {
 		__flush_page_to_ram(pte);
 		flush_tlb_kernel_page(pte);
@@ -29,7 +29,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	struct page *page = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	struct page *page = alloc_page(GFP_KERNEL|__GFP_ZERO);
 	pte_t *pte;
 
 	if(!page)
diff --git a/arch/m68k/include/asm/sun3_pgalloc.h b/arch/m68k/include/asm/sun3_pgalloc.h
--- a/arch/m68k/include/asm/sun3_pgalloc.h
+++ b/arch/m68k/include/asm/sun3_pgalloc.h
@@ -41,7 +41,7 @@ do {							\
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	unsigned long page = __get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	unsigned long page = __get_free_page(GFP_KERNEL);
 
 	if (!page)
 		return NULL;
@@ -53,7 +53,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 					unsigned long address)
 {
-        struct page *page = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
+        struct page *page = alloc_page(GFP_KERNEL);
 
 	if (page == NULL)
 		return NULL;
diff --git a/arch/microblaze/include/asm/pgalloc.h b/arch/microblaze/include/asm/pgalloc.h
--- a/arch/microblaze/include/asm/pgalloc.h
+++ b/arch/microblaze/include/asm/pgalloc.h
@@ -114,14 +114,13 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 		unsigned long address)
 {
 	struct page *ptepage;
+	int flags = GFP_KERNEL;
 
 #ifdef CONFIG_HIGHPTE
-	int flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_REPEAT;
-#else
-	int flags = GFP_KERNEL | __GFP_REPEAT;
+	flags |= __GFP_HIGHMEM;
 #endif
 
-	ptepage = alloc_pages(flags, 0);
+	ptepage = alloc_page(flags);
 	if (ptepage)
 		clear_highpage(ptepage);
 	return ptepage;
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -245,8 +245,7 @@ __init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 {
 	pte_t *pte;
 	if (mem_init_done) {
-		pte = (pte_t *)__get_free_page(GFP_KERNEL |
-					__GFP_REPEAT | __GFP_ZERO);
+		pte = (pte_t *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
 	} else {
 		pte = (pte_t *)early_get_page();
 		if (pte)
diff --git a/arch/mn10300/mm/pgtable.c b/arch/mn10300/mm/pgtable.c
--- a/arch/mn10300/mm/pgtable.c
+++ b/arch/mn10300/mm/pgtable.c
@@ -64,7 +64,7 @@ void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags)
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL);
 	if (pte)
 		clear_page(pte);
 	return pte;
@@ -75,9 +75,9 @@ struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 	struct page *pte;
 
 #ifdef CONFIG_HIGHPTE
-	pte = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT, 0);
+	pte = alloc_page(GFP_KERNEL|__GFP_HIGHMEM);
 #else
-	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
+	pte = alloc_page(GFP_KERNEL);
 #endif
 	if (pte)
 		clear_highpage(pte);
diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -120,7 +120,7 @@ pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
 static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	struct page *page = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	struct page *page = alloc_page(GFP_KERNEL|__GFP_ZERO);
 	if (page)
 		pgtable_page_ctor(page);
 	return page;
@@ -129,7 +129,7 @@ pte_alloc_one(struct mm_struct *mm, unsigned long address)
 static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	return pte;
 }
 
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -103,7 +103,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-        return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+        return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
--- a/arch/powerpc/mm/pgtable_32.c
+++ b/arch/powerpc/mm/pgtable_32.c
@@ -102,7 +102,7 @@ __init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long add
 	extern void *early_get_page(void);
 
 	if (mem_init_done) {
-		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	} else {
 		pte = (pte_t *)early_get_page();
 		if (pte)
@@ -115,9 +115,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *ptepage;
 
-	gfp_t flags = GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO;
-
-	ptepage = alloc_pages(flags, 0);
+	ptepage = alloc_page(GFP_KERNEL | __GFP_ZERO);
 	if (!ptepage)
 		return NULL;
 	pgtable_page_ctor(ptepage);
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -192,7 +192,7 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
 	}
 	if (!page) {
 		spin_unlock(&mm->context.list_lock);
-		page = alloc_page(GFP_KERNEL|__GFP_REPEAT);
+		page = alloc_page(GFP_KERNEL);
 		if (!page)
 			return NULL;
 		pgtable_page_ctor(page);
diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -34,7 +34,7 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	return quicklist_alloc(QUICK_PT, GFP_KERNEL, NULL);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
@@ -43,7 +43,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 	struct page *page;
 	void *pg;
 
-	pg = quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	pg = quicklist_alloc(QUICK_PT, GFP_KERNEL, NULL);
 	if (!pg)
 		return NULL;
 	page = virt_to_page(pg);
diff --git a/arch/sparc/mm/sun4c.c b/arch/sparc/mm/sun4c.c
--- a/arch/sparc/mm/sun4c.c
+++ b/arch/sparc/mm/sun4c.c
@@ -1831,7 +1831,7 @@ static pte_t *sun4c_pte_alloc_one_kernel(struct mm_struct *mm, unsigned long add
 	if ((pte = sun4c_pte_alloc_one_fast(mm, address)) != NULL)
 		return pte;
 
-	pte = (pte_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	pte = (pte_t *)get_zeroed_page(GFP_KERNEL);
 	return pte;
 }
 
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -288,7 +288,7 @@ pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
 	pte_t *pte;
 
-	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	return pte;
 }
 
@@ -296,7 +296,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
 
-	pte = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte = alloc_page(GFP_KERNEL|__GFP_ZERO);
 	if (pte)
 		pgtable_page_ctor(pte);
 	return pte;
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -80,7 +80,7 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 #if PAGETABLE_LEVELS > 2
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pmd_t *)get_zeroed_page(GFP_KERNEL);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -116,7 +116,7 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pud_t *)get_zeroed_page(GFP_KERNEL);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -5,7 +5,7 @@
 #include <asm/tlb.h>
 #include <asm/fixmap.h>
 
-#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
+#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO
 
 #ifdef CONFIG_HIGHPTE
 #define PGALLOC_USER_GFP __GFP_HIGHMEM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
