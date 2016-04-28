Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 747376B0263
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:24:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k200so71854317lfg.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:24:15 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id bd7si10838628wjb.241.2016.04.28.06.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 06:24:13 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id g17so41296471wme.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:24:13 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 01/20] tree wide: get rid of __GFP_REPEAT for order-0 allocations part I
Date: Thu, 28 Apr 2016 15:23:47 +0200
Message-Id: <1461849846-27209-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations. Yet we have
the full kernel tree with its usage for apparently order-0 allocations.
This is really confusing because __GFP_REPEAT is explicitly documented
to allow allocation failures which is a weaker semantic than the current
order-0 has (basically nofail).

Let's simply drop __GFP_REPEAT from those places. This would allow
to identify place which really need allocator to retry harder and
formulate a more specific semantic for what the flag is supposed to do
actually.

Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/alpha/include/asm/pgalloc.h         | 4 ++--
 arch/arm/include/asm/pgalloc.h           | 2 +-
 arch/avr32/include/asm/pgalloc.h         | 6 +++---
 arch/cris/include/asm/pgalloc.h          | 4 ++--
 arch/frv/mm/pgalloc.c                    | 6 +++---
 arch/hexagon/include/asm/pgalloc.h       | 4 ++--
 arch/m68k/include/asm/mcf_pgalloc.h      | 4 ++--
 arch/m68k/include/asm/motorola_pgalloc.h | 4 ++--
 arch/m68k/include/asm/sun3_pgalloc.h     | 4 ++--
 arch/metag/include/asm/pgalloc.h         | 5 ++---
 arch/microblaze/include/asm/pgalloc.h    | 4 ++--
 arch/microblaze/mm/pgtable.c             | 3 +--
 arch/mn10300/mm/pgtable.c                | 6 +++---
 arch/openrisc/include/asm/pgalloc.h      | 2 +-
 arch/openrisc/mm/ioremap.c               | 2 +-
 arch/parisc/include/asm/pgalloc.h        | 4 ++--
 arch/powerpc/include/asm/pgalloc-64.h    | 2 +-
 arch/powerpc/mm/pgtable_32.c             | 4 ++--
 arch/powerpc/mm/pgtable_64.c             | 3 +--
 arch/sh/include/asm/pgalloc.h            | 4 ++--
 arch/sparc/mm/init_64.c                  | 6 ++----
 arch/um/kernel/mem.c                     | 4 ++--
 arch/x86/include/asm/pgalloc.h           | 4 ++--
 arch/x86/xen/p2m.c                       | 2 +-
 arch/xtensa/include/asm/pgalloc.h        | 2 +-
 drivers/block/aoe/aoecmd.c               | 2 +-
 26 files changed, 46 insertions(+), 51 deletions(-)

diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pgalloc.h
index aab14a019c20..c2ebb6f36c9d 100644
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
index 19cfab526d13..20febb368844 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -29,7 +29,7 @@
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL | __GFP_REPEAT);
+	return (pmd_t *)get_zeroed_page(GFP_KERNEL);
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
diff --git a/arch/avr32/include/asm/pgalloc.h b/arch/avr32/include/asm/pgalloc.h
index 1aba19d68c5e..db039cb368be 100644
--- a/arch/avr32/include/asm/pgalloc.h
+++ b/arch/avr32/include/asm/pgalloc.h
@@ -43,7 +43,7 @@ static inline void pgd_ctor(void *x)
  */
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
-	return quicklist_alloc(QUICK_PGD, GFP_KERNEL | __GFP_REPEAT, pgd_ctor);
+	return quicklist_alloc(QUICK_PGD, GFP_KERNEL, pgd_ctor);
 }
 
 static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
@@ -54,7 +54,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	return quicklist_alloc(QUICK_PT, GFP_KERNEL, NULL);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
@@ -63,7 +63,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 	struct page *page;
 	void *pg;
 
-	pg = quicklist_alloc(QUICK_PT, GFP_KERNEL | __GFP_REPEAT, NULL);
+	pg = quicklist_alloc(QUICK_PT, GFP_KERNEL, NULL);
 	if (!pg)
 		return NULL;
 
diff --git a/arch/cris/include/asm/pgalloc.h b/arch/cris/include/asm/pgalloc.h
index 235ece437ddd..42f1affb9c2d 100644
--- a/arch/cris/include/asm/pgalloc.h
+++ b/arch/cris/include/asm/pgalloc.h
@@ -24,14 +24,14 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-  	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
  	return pte;
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
-	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	pte = alloc_pages(GFP_KERNEL|__GFP_ZERO, 0);
 	if (!pte)
 		return NULL;
 	if (!pgtable_page_ctor(pte)) {
diff --git a/arch/frv/mm/pgalloc.c b/arch/frv/mm/pgalloc.c
index 41907d25ed38..c9ed14f6c67d 100644
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
+	page = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM, 0);
 #else
-	page = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
+	page = alloc_pages(GFP_KERNEL, 0);
 #endif
 	if (!page)
 		return NULL;
diff --git a/arch/hexagon/include/asm/pgalloc.h b/arch/hexagon/include/asm/pgalloc.h
index 77da3b0ae3c2..eeebf862c46c 100644
--- a/arch/hexagon/include/asm/pgalloc.h
+++ b/arch/hexagon/include/asm/pgalloc.h
@@ -64,7 +64,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 {
 	struct page *pte;
 
-	pte = alloc_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+	pte = alloc_page(GFP_KERNEL | __GFP_ZERO);
 	if (!pte)
 		return NULL;
 	if (!pgtable_page_ctor(pte)) {
@@ -78,7 +78,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	gfp_t flags =  GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO;
+	gfp_t flags =  GFP_KERNEL | __GFP_ZERO;
 	return (pte_t *) __get_free_page(flags);
 }
 
diff --git a/arch/m68k/include/asm/mcf_pgalloc.h b/arch/m68k/include/asm/mcf_pgalloc.h
index f9924fbcfe42..fb95aed5f428 100644
--- a/arch/m68k/include/asm/mcf_pgalloc.h
+++ b/arch/m68k/include/asm/mcf_pgalloc.h
@@ -14,7 +14,7 @@ extern const char bad_pmd_string[];
 extern inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	unsigned long address)
 {
-	unsigned long page = __get_free_page(GFP_DMA|__GFP_REPEAT);
+	unsigned long page = __get_free_page(GFP_DMA);
 
 	if (!page)
 		return NULL;
@@ -51,7 +51,7 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page,
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 	unsigned long address)
 {
-	struct page *page = alloc_pages(GFP_DMA|__GFP_REPEAT, 0);
+	struct page *page = alloc_pages(GFP_DMA, 0);
 	pte_t *pte;
 
 	if (!page)
diff --git a/arch/m68k/include/asm/motorola_pgalloc.h b/arch/m68k/include/asm/motorola_pgalloc.h
index 24bcba496c75..c895b987202c 100644
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
@@ -32,7 +32,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addres
 	struct page *page;
 	pte_t *pte;
 
-	page = alloc_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, 0);
+	page = alloc_pages(GFP_KERNEL|__GFP_ZERO, 0);
 	if(!page)
 		return NULL;
 	if (!pgtable_page_ctor(page)) {
diff --git a/arch/m68k/include/asm/sun3_pgalloc.h b/arch/m68k/include/asm/sun3_pgalloc.h
index 0931388de47f..1901f61f926f 100644
--- a/arch/m68k/include/asm/sun3_pgalloc.h
+++ b/arch/m68k/include/asm/sun3_pgalloc.h
@@ -37,7 +37,7 @@ do {							\
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	unsigned long page = __get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	unsigned long page = __get_free_page(GFP_KERNEL);
 
 	if (!page)
 		return NULL;
@@ -49,7 +49,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 					unsigned long address)
 {
-        struct page *page = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
+        struct page *page = alloc_pages(GFP_KERNEL, 0);
 
 	if (page == NULL)
 		return NULL;
diff --git a/arch/metag/include/asm/pgalloc.h b/arch/metag/include/asm/pgalloc.h
index 3104df0a4822..c2caa1ee4360 100644
--- a/arch/metag/include/asm/pgalloc.h
+++ b/arch/metag/include/asm/pgalloc.h
@@ -42,8 +42,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT |
-					      __GFP_ZERO);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
 	return pte;
 }
 
@@ -51,7 +50,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 				      unsigned long address)
 {
 	struct page *pte;
-	pte = alloc_pages(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0);
+	pte = alloc_pages(GFP_KERNEL  | __GFP_ZERO, 0);
 	if (!pte)
 		return NULL;
 	if (!pgtable_page_ctor(pte)) {
diff --git a/arch/microblaze/include/asm/pgalloc.h b/arch/microblaze/include/asm/pgalloc.h
index 61436d69775c..7c89390c0c13 100644
--- a/arch/microblaze/include/asm/pgalloc.h
+++ b/arch/microblaze/include/asm/pgalloc.h
@@ -116,9 +116,9 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 	struct page *ptepage;
 
 #ifdef CONFIG_HIGHPTE
-	int flags = GFP_KERNEL | __GFP_HIGHMEM | __GFP_REPEAT;
+	int flags = GFP_KERNEL | __GFP_HIGHMEM;
 #else
-	int flags = GFP_KERNEL | __GFP_REPEAT;
+	int flags = GFP_KERNEL;
 #endif
 
 	ptepage = alloc_pages(flags, 0);
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
index 4f4520e779a5..eb99fcc76088 100644
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -239,8 +239,7 @@ __init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
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
index e77a7c728081..9577cf768875 100644
--- a/arch/mn10300/mm/pgtable.c
+++ b/arch/mn10300/mm/pgtable.c
@@ -63,7 +63,7 @@ void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags)
 
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL);
 	if (pte)
 		clear_page(pte);
 	return pte;
@@ -74,9 +74,9 @@ struct page *pte_alloc_one(struct mm_struct *mm, unsigned long address)
 	struct page *pte;
 
 #ifdef CONFIG_HIGHPTE
-	pte = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM|__GFP_REPEAT, 0);
+	pte = alloc_pages(GFP_KERNEL|__GFP_HIGHMEM, 0);
 #else
-	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
+	pte = alloc_pages(GFP_KERNEL, 0);
 #endif
 	if (!pte)
 		return NULL;
diff --git a/arch/openrisc/include/asm/pgalloc.h b/arch/openrisc/include/asm/pgalloc.h
index 21484e5b9e9a..87eebd185089 100644
--- a/arch/openrisc/include/asm/pgalloc.h
+++ b/arch/openrisc/include/asm/pgalloc.h
@@ -77,7 +77,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 					 unsigned long address)
 {
 	struct page *pte;
-	pte = alloc_pages(GFP_KERNEL|__GFP_REPEAT, 0);
+	pte = alloc_pages(GFP_KERNEL, 0);
 	if (!pte)
 		return NULL;
 	clear_page(page_address(pte));
diff --git a/arch/openrisc/mm/ioremap.c b/arch/openrisc/mm/ioremap.c
index 62b08ef392be..5b2a95116e8f 100644
--- a/arch/openrisc/mm/ioremap.c
+++ b/arch/openrisc/mm/ioremap.c
@@ -122,7 +122,7 @@ pte_t __init_refok *pte_alloc_one_kernel(struct mm_struct *mm,
 	pte_t *pte;
 
 	if (likely(mem_init_done)) {
-		pte = (pte_t *) __get_free_page(GFP_KERNEL | __GFP_REPEAT);
+		pte = (pte_t *) __get_free_page(GFP_KERNEL);
 	} else {
 		pte = (pte_t *) alloc_bootmem_low_pages(PAGE_SIZE);
 #if 0
diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index f2fd327dce2e..52c3defb40c9 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -124,7 +124,7 @@ pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
 static inline pgtable_t
 pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	struct page *page = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	struct page *page = alloc_page(GFP_KERNEL|__GFP_ZERO);
 	if (!page)
 		return NULL;
 	if (!pgtable_page_ctor(page)) {
@@ -137,7 +137,7 @@ pte_alloc_one(struct mm_struct *mm, unsigned long address)
 static inline pte_t *
 pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
 {
-	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	return pte;
 }
 
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/pgalloc-64.h
index 8d5fc3ac43da..5dcfde5dc673 100644
--- a/arch/powerpc/include/asm/pgalloc-64.h
+++ b/arch/powerpc/include/asm/pgalloc-64.h
@@ -88,7 +88,7 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
 {
-	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
+	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
 }
 
 static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
index bf7bf32b54f8..7f922f557936 100644
--- a/arch/powerpc/mm/pgtable_32.c
+++ b/arch/powerpc/mm/pgtable_32.c
@@ -84,7 +84,7 @@ __init_refok pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long add
 	pte_t *pte;
 
 	if (slab_is_available()) {
-		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+		pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	} else {
 		pte = __va(memblock_alloc(PAGE_SIZE, PAGE_SIZE));
 		if (pte)
@@ -97,7 +97,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *ptepage;
 
-	gfp_t flags = GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO;
+	gfp_t flags = GFP_KERNEL | __GFP_ZERO;
 
 	ptepage = alloc_pages(flags, 0);
 	if (!ptepage)
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 347106080bb1..03cc73e86675 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -386,8 +386,7 @@ static pte_t *get_from_cache(struct mm_struct *mm)
 static pte_t *__alloc_for_cache(struct mm_struct *mm, int kernel)
 {
 	void *ret = NULL;
-	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
-				       __GFP_REPEAT | __GFP_ZERO);
+	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO);
 	if (!page)
 		return NULL;
 	if (!kernel && !pgtable_page_ctor(page)) {
diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
index a33673b3687d..f3f42c84c40f 100644
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
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 09e838801e39..4b905ea1f1c8 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2716,8 +2716,7 @@ void __flush_tlb_all(void)
 pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 			    unsigned long address)
 {
-	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
-				       __GFP_REPEAT | __GFP_ZERO);
+	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO);
 	pte_t *pte = NULL;
 
 	if (page)
@@ -2729,8 +2728,7 @@ pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 pgtable_t pte_alloc_one(struct mm_struct *mm,
 			unsigned long address)
 {
-	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
-				       __GFP_REPEAT | __GFP_ZERO);
+	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO);
 	if (!page)
 		return NULL;
 	if (!pgtable_page_ctor(page)) {
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index b2a2dff50b4e..e7437ec62710 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -204,7 +204,7 @@ pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 {
 	pte_t *pte;
 
-	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	return pte;
 }
 
@@ -212,7 +212,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	struct page *pte;
 
-	pte = alloc_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO);
+	pte = alloc_page(GFP_KERNEL|__GFP_ZERO);
 	if (!pte)
 		return NULL;
 	if (!pgtable_page_ctor(pte)) {
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index bf7f8b55b0f9..574c23cf761a 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -81,7 +81,7 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *page;
-	page = alloc_pages(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO, 0);
+	page = alloc_pages(GFP_KERNEL |  __GFP_ZERO, 0);
 	if (!page)
 		return NULL;
 	if (!pgtable_pmd_page_ctor(page)) {
@@ -125,7 +125,7 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pud_t *)get_zeroed_page(GFP_KERNEL);
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
index cab9f766bb06..dd2a49a8aacc 100644
--- a/arch/x86/xen/p2m.c
+++ b/arch/x86/xen/p2m.c
@@ -182,7 +182,7 @@ static void * __ref alloc_p2m_page(void)
 	if (unlikely(!slab_is_available()))
 		return alloc_bootmem_align(PAGE_SIZE, PAGE_SIZE);
 
-	return (void *)__get_free_page(GFP_KERNEL | __GFP_REPEAT);
+	return (void *)__get_free_page(GFP_KERNEL);
 }
 
 static void __ref free_p2m_page(void *p)
diff --git a/arch/xtensa/include/asm/pgalloc.h b/arch/xtensa/include/asm/pgalloc.h
index d38eb9237e64..1065bc8bcae5 100644
--- a/arch/xtensa/include/asm/pgalloc.h
+++ b/arch/xtensa/include/asm/pgalloc.h
@@ -44,7 +44,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	pte_t *ptep;
 	int i;
 
-	ptep = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
+	ptep = (pte_t *)__get_free_page(GFP_KERNEL);
 	if (!ptep)
 		return NULL;
 	for (i = 0; i < 1024; i++)
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index d597e432e195..ab19adb07a12 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -1750,7 +1750,7 @@ aoecmd_init(void)
 	int ret;
 
 	/* get_zeroed_page returns page with ref count 1 */
-	p = (void *) get_zeroed_page(GFP_KERNEL | __GFP_REPEAT);
+	p = (void *) get_zeroed_page(GFP_KERNEL);
 	if (!p)
 		return -ENOMEM;
 	empty_page = virt_to_page(p);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
