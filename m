Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1AEC6B037E
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 17:17:54 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id i132so6829782ioe.5
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 14:17:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w78sor1249702iod.65.2017.06.07.14.17.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 14:17:53 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [RFC v4 3/3] xpfo: add support for hugepages
Date: Wed,  7 Jun 2017 15:16:53 -0600
Message-Id: <20170607211653.14536-4-tycho@docker.com>
In-Reply-To: <20170607211653.14536-1-tycho@docker.com>
References: <20170607211653.14536-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Juerg Haefliger <juergh@gmail.com>, kernel-hardening@lists.openwall.com, Tycho Andersen <tycho@docker.com>

Based on an earlier draft by Marco Benatto.

Signed-off-by: Tycho Andersen <tycho@docker.com>
CC: Juerg Haefliger <juergh@gmail.com>
---
 arch/x86/include/asm/pgtable.h | 22 +++++++++++++++
 arch/x86/mm/pageattr.c         | 21 +++------------
 arch/x86/mm/xpfo.c             | 61 +++++++++++++++++++++++++++++++++++++++++-
 include/linux/xpfo.h           |  1 +
 mm/xpfo.c                      |  8 ++----
 5 files changed, 88 insertions(+), 25 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index f5af95a0c6b8..58bb43d8b9c1 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1185,6 +1185,28 @@ static inline u16 pte_flags_pkey(unsigned long pte_flags)
 #endif
 }
 
+/*
+ * The current flushing context - we pass it instead of 5 arguments:
+ */
+struct cpa_data {
+	unsigned long	*vaddr;
+	pgd_t		*pgd;
+	pgprot_t	mask_set;
+	pgprot_t	mask_clr;
+	unsigned long	numpages;
+	int		flags;
+	unsigned long	pfn;
+	unsigned	force_split : 1;
+	int		curpage;
+	struct page	**pages;
+};
+
+int
+try_preserve_large_page(pte_t *kpte, unsigned long address,
+			struct cpa_data *cpa);
+int split_large_page(struct cpa_data *cpa, pte_t *kpte,
+		     unsigned long address);
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 1dcd2be4cce4..6d6a78e6e023 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -26,21 +26,6 @@
 #include <asm/pat.h>
 #include <asm/set_memory.h>
 
-/*
- * The current flushing context - we pass it instead of 5 arguments:
- */
-struct cpa_data {
-	unsigned long	*vaddr;
-	pgd_t		*pgd;
-	pgprot_t	mask_set;
-	pgprot_t	mask_clr;
-	unsigned long	numpages;
-	int		flags;
-	unsigned long	pfn;
-	unsigned	force_split : 1;
-	int		curpage;
-	struct page	**pages;
-};
 
 /*
  * Serialize cpa() (for !DEBUG_PAGEALLOC which uses large identity mappings)
@@ -506,7 +491,7 @@ static void __set_pmd_pte(pte_t *kpte, unsigned long address, pte_t pte)
 #endif
 }
 
-static int
+int
 try_preserve_large_page(pte_t *kpte, unsigned long address,
 			struct cpa_data *cpa)
 {
@@ -740,8 +725,8 @@ __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 	return 0;
 }
 
-static int split_large_page(struct cpa_data *cpa, pte_t *kpte,
-			    unsigned long address)
+int split_large_page(struct cpa_data *cpa, pte_t *kpte,
+		     unsigned long address)
 {
 	struct page *base;
 
diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
index c24b06c9b4ab..818da3ebc077 100644
--- a/arch/x86/mm/xpfo.c
+++ b/arch/x86/mm/xpfo.c
@@ -13,11 +13,70 @@
 
 #include <linux/mm.h>
 
+#include <asm/tlbflush.h>
+
 /* Update a single kernel page table entry */
 inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
 {
 	unsigned int level;
 	pte_t *pte = lookup_address((unsigned long)kaddr, &level);
 
-	set_pte_atomic(pte, pfn_pte(page_to_pfn(page), canon_pgprot(prot)));
+
+	BUG_ON(!pte);
+
+	switch (level) {
+	case PG_LEVEL_4K:
+		set_pte_atomic(pte, pfn_pte(page_to_pfn(page), canon_pgprot(prot)));
+		break;
+	case PG_LEVEL_2M:
+	case PG_LEVEL_1G: {
+		struct cpa_data cpa;
+		int do_split;
+
+		memset(&cpa, 0, sizeof(cpa));
+		cpa.vaddr = kaddr;
+		cpa.pages = &page;
+		cpa.mask_set = prot;
+		pgprot_val(cpa.mask_clr) = ~pgprot_val(prot);
+		cpa.numpages = 1;
+		cpa.flags = 0;
+		cpa.curpage = 0;
+		cpa.force_split = 0;
+
+		do_split = try_preserve_large_page(pte, (unsigned long)kaddr, &cpa);
+		if (do_split < 0)
+			BUG_ON(split_large_page(&cpa, pte, (unsigned long)kaddr));
+
+		break;
+	}
+	default:
+		BUG();
+	}
+
+}
+
+inline void xpfo_flush_kernel_page(struct page *page, int order)
+{
+	int level;
+	unsigned long size, kaddr;
+
+	kaddr = (unsigned long)page_address(page);
+	lookup_address(kaddr, &level);
+
+
+	switch (level) {
+	case PG_LEVEL_4K:
+		size = PAGE_SIZE;
+		break;
+	case PG_LEVEL_2M:
+		size = PMD_SIZE;
+		break;
+	case PG_LEVEL_1G:
+		size = PUD_SIZE;
+		break;
+	default:
+		BUG();
+	}
+
+	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
 }
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 031cbee22a41..a0f0101720f6 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -19,6 +19,7 @@
 extern struct page_ext_operations page_xpfo_ops;
 
 void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
+void xpfo_flush_kernel_page(struct page *page, int order);
 
 void xpfo_kmap(void *kaddr, struct page *page);
 void xpfo_kunmap(void *kaddr, struct page *page);
diff --git a/mm/xpfo.c b/mm/xpfo.c
index 8384058136b1..895de28108da 100644
--- a/mm/xpfo.c
+++ b/mm/xpfo.c
@@ -78,7 +78,6 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
 {
 	int i, flush_tlb = 0;
 	struct xpfo *xpfo;
-	unsigned long kaddr;
 
 	if (!static_branch_unlikely(&xpfo_inited))
 		return;
@@ -109,11 +108,8 @@ void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
 		}
 	}
 
-	if (flush_tlb) {
-		kaddr = (unsigned long)page_address(page);
-		flush_tlb_kernel_range(kaddr, kaddr + (1 << order) *
-				       PAGE_SIZE);
-	}
+	if (flush_tlb)
+		xpfo_flush_kernel_page(page, order);
 }
 
 void xpfo_free_pages(struct page *page, int order)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
