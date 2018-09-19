Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3878E0004
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 17:01:06 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id v9-v6so3064262ply.13
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:01:06 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u10-v6si17660550pga.37.2018.09.19.14.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 14:01:04 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 6/7] mm/gup: Combine parameters into struct
Date: Wed, 19 Sep 2018 15:02:49 -0600
Message-Id: <20180919210250.28858-7-keith.busch@intel.com>
In-Reply-To: <20180919210250.28858-1-keith.busch@intel.com>
References: <20180919210250.28858-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

This will make it easier to add new parameters that we may wish to
thread through these function calls.

Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 include/linux/huge_mm.h |  12 +--
 include/linux/hugetlb.h |   2 +-
 include/linux/mm.h      |  21 ++++-
 mm/gup.c                | 238 +++++++++++++++++++++++-------------------------
 mm/huge_memory.c        |  32 +++----
 mm/nommu.c              |   6 +-
 6 files changed, 151 insertions(+), 160 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 99c19b06d9a4..7d22e2c7f154 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -212,10 +212,8 @@ static inline int hpage_nr_pages(struct page *page)
 	return 1;
 }
 
-struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, int flags);
-struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
-		pud_t *pud, int flags);
+struct page *follow_devmap_pmd(struct follow_page_context *ctx, pmd_t *pmd);
+struct page *follow_devmap_pud(struct follow_page_context *ctx, pud_t *pud);
 
 extern vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
@@ -343,14 +341,12 @@ static inline void mm_put_huge_zero_page(struct mm_struct *mm)
 	return;
 }
 
-static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
-		unsigned long addr, pmd_t *pmd, int flags)
+static inline struct page *follow_devmap_pmd(struct gup_context *ctx, pmd_t *pmd)
 {
 	return NULL;
 }
 
-static inline struct page *follow_devmap_pud(struct vm_area_struct *vma,
-		unsigned long addr, pud_t *pud, int flags)
+static inline struct page *follow_devmap_pud(struct gup_context *ctx, pud_t *pud)
 {
 	return NULL;
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6b68e345f0ca..64b675863793 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -180,7 +180,7 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 static inline void hugetlb_show_meminfo(void)
 {
 }
-#define follow_huge_pd(vma, addr, hpd, flags, pdshift) NULL
+#define follow_huge_pd(ctx, hpd, pdshift)	NULL
 #define follow_huge_pmd(mm, addr, pmd, flags)	NULL
 #define follow_huge_pud(mm, addr, pud, flags)	NULL
 #define follow_huge_pgd(mm, addr, pgd, flags)	NULL
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..f1fd241c9071 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -378,6 +378,13 @@ struct vm_fault {
 					 */
 };
 
+struct follow_page_context {
+	struct vm_area_struct *vma;
+	unsigned long address;
+	unsigned int page_mask;
+	unsigned int flags;
+};
+
 /* page entry size for vm->huge_fault() */
 enum page_entry_size {
 	PE_SIZE_PTE = 0,
@@ -2534,15 +2541,19 @@ static inline vm_fault_t vmf_error(int err)
 	return VM_FAULT_SIGBUS;
 }
 
-struct page *follow_page_mask(struct vm_area_struct *vma,
-			      unsigned long address, unsigned int foll_flags,
-			      unsigned int *page_mask);
+struct page *follow_page_mask(struct follow_page_context *ctx);
 
 static inline struct page *follow_page(struct vm_area_struct *vma,
 		unsigned long address, unsigned int foll_flags)
 {
-	unsigned int unused_page_mask;
-	return follow_page_mask(vma, address, foll_flags, &unused_page_mask);
+	struct follow_page_context ctx = {
+		.vma = vma,
+		.address = address,
+		.page_mask = 0,
+		.flags = foll_flags,
+	};
+
+	return follow_page_mask(&ctx);
 }
 
 #define FOLL_WRITE	0x01	/* check pte is writable */
diff --git a/mm/gup.c b/mm/gup.c
index 1abc8b4afff6..a61a6874c80c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -20,8 +20,7 @@
 
 #include "internal.h"
 
-static struct page *no_page_table(struct vm_area_struct *vma,
-		unsigned int flags)
+static struct page *no_page_table(struct follow_page_context *ctx)
 {
 	/*
 	 * When core dumping an enormous anonymous area that nobody
@@ -31,28 +30,28 @@ static struct page *no_page_table(struct vm_area_struct *vma,
 	 * But we can only make this optimization where a hole would surely
 	 * be zero-filled if handle_mm_fault() actually did handle it.
 	 */
-	if ((flags & FOLL_DUMP) && (!vma->vm_ops || !vma->vm_ops->fault))
+	if ((ctx->flags & FOLL_DUMP) && (!ctx->vma->vm_ops ||
+					 !ctx->vma->vm_ops->fault))
 		return ERR_PTR(-EFAULT);
 	return NULL;
 }
 
-static int follow_pfn_pte(struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, unsigned int flags)
+static int follow_pfn_pte(struct follow_page_context *ctx, pte_t *pte)
 {
 	/* No page to get reference */
-	if (flags & FOLL_GET)
+	if (ctx->flags & FOLL_GET)
 		return -EFAULT;
 
-	if (flags & FOLL_TOUCH) {
+	if (ctx->flags & FOLL_TOUCH) {
 		pte_t entry = *pte;
 
-		if (flags & FOLL_WRITE)
+		if (ctx->flags & FOLL_WRITE)
 			entry = pte_mkdirty(entry);
 		entry = pte_mkyoung(entry);
 
 		if (!pte_same(*pte, entry)) {
-			set_pte_at(vma->vm_mm, address, pte, entry);
-			update_mmu_cache(vma, address, pte);
+			set_pte_at(ctx->vma->vm_mm, ctx->address, pte, entry);
+			update_mmu_cache(ctx->vma, ctx->address, pte);
 		}
 	}
 
@@ -70,10 +69,9 @@ static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
 		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
 }
 
-static struct page *follow_page_pte(struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd, unsigned int flags)
+static struct page *follow_page_pte(struct follow_page_context *ctx, pmd_t *pmd)
 {
-	struct mm_struct *mm = vma->vm_mm;
+	struct mm_struct *mm = ctx->vma->vm_mm;
 	struct dev_pagemap *pgmap = NULL;
 	struct page *page;
 	spinlock_t *ptl;
@@ -81,9 +79,9 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 
 retry:
 	if (unlikely(pmd_bad(*pmd)))
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	ptep = pte_offset_map_lock(mm, pmd, ctx->address, &ptl);
 	pte = *ptep;
 	if (!pte_present(pte)) {
 		swp_entry_t entry;
@@ -92,7 +90,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		 * even while it is being migrated, so for that case we
 		 * need migration_entry_wait().
 		 */
-		if (likely(!(flags & FOLL_MIGRATION)))
+		if (likely(!(ctx->flags & FOLL_MIGRATION)))
 			goto no_page;
 		if (pte_none(pte))
 			goto no_page;
@@ -100,18 +98,18 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		if (!is_migration_entry(entry))
 			goto no_page;
 		pte_unmap_unlock(ptep, ptl);
-		migration_entry_wait(mm, pmd, address);
+		migration_entry_wait(mm, pmd, ctx->address);
 		goto retry;
 	}
-	if ((flags & FOLL_NUMA) && pte_protnone(pte))
+	if ((ctx->flags & FOLL_NUMA) && pte_protnone(pte))
 		goto no_page;
-	if ((flags & FOLL_WRITE) && !can_follow_write_pte(pte, flags)) {
+	if ((ctx->flags & FOLL_WRITE) && !can_follow_write_pte(pte, ctx->flags)) {
 		pte_unmap_unlock(ptep, ptl);
 		return NULL;
 	}
 
-	page = vm_normal_page(vma, address, pte);
-	if (!page && pte_devmap(pte) && (flags & FOLL_GET)) {
+	page = vm_normal_page(ctx->vma, ctx->address, pte);
+	if (!page && pte_devmap(pte) && (ctx->flags & FOLL_GET)) {
 		/*
 		 * Only return device mapping pages in the FOLL_GET case since
 		 * they are only valid while holding the pgmap reference.
@@ -122,7 +120,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		else
 			goto no_page;
 	} else if (unlikely(!page)) {
-		if (flags & FOLL_DUMP) {
+		if (ctx->flags & FOLL_DUMP) {
 			/* Avoid special (like zero) pages in core dumps */
 			page = ERR_PTR(-EFAULT);
 			goto out;
@@ -133,13 +131,13 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		} else {
 			int ret;
 
-			ret = follow_pfn_pte(vma, address, ptep, flags);
+			ret = follow_pfn_pte(ctx, ptep);
 			page = ERR_PTR(ret);
 			goto out;
 		}
 	}
 
-	if (flags & FOLL_SPLIT && PageTransCompound(page)) {
+	if (ctx->flags & FOLL_SPLIT && PageTransCompound(page)) {
 		int ret;
 		get_page(page);
 		pte_unmap_unlock(ptep, ptl);
@@ -152,7 +150,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		goto retry;
 	}
 
-	if (flags & FOLL_GET) {
+	if (ctx->flags & FOLL_GET) {
 		get_page(page);
 
 		/* drop the pgmap reference now that we hold the page */
@@ -161,8 +159,8 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 			pgmap = NULL;
 		}
 	}
-	if (flags & FOLL_TOUCH) {
-		if ((flags & FOLL_WRITE) &&
+	if (ctx->flags & FOLL_TOUCH) {
+		if ((ctx->flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
 			set_page_dirty(page);
 		/*
@@ -172,7 +170,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		 */
 		mark_page_accessed(page);
 	}
-	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
+	if ((ctx->flags & FOLL_MLOCK) && (ctx->vma->vm_flags & VM_LOCKED)) {
 		/* Do not mlock pte-mapped THP */
 		if (PageTransCompound(page))
 			goto out;
@@ -205,44 +203,42 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 	pte_unmap_unlock(ptep, ptl);
 	if (!pte_none(pte))
 		return NULL;
-	return no_page_table(vma, flags);
+	return no_page_table(ctx);
 }
 
-static struct page *follow_pmd_mask(struct vm_area_struct *vma,
-				    unsigned long address, pud_t *pudp,
-				    unsigned int flags, unsigned int *page_mask)
+static struct page *follow_pmd_mask(struct follow_page_context *ctx, pud_t *pudp)
 {
 	pmd_t *pmd, pmdval;
 	spinlock_t *ptl;
 	struct page *page;
-	struct mm_struct *mm = vma->vm_mm;
+	struct mm_struct *mm = ctx->vma->vm_mm;
 
-	pmd = pmd_offset(pudp, address);
+	pmd = pmd_offset(pudp, ctx->address);
 	/*
 	 * The READ_ONCE() will stabilize the pmdval in a register or
 	 * on the stack so that it will stop changing under the code.
 	 */
 	pmdval = READ_ONCE(*pmd);
 	if (pmd_none(pmdval))
-		return no_page_table(vma, flags);
-	if (pmd_huge(pmdval) && vma->vm_flags & VM_HUGETLB) {
-		page = follow_huge_pmd(mm, address, pmd, flags);
+		return no_page_table(ctx);
+	if (pmd_huge(pmdval) && ctx->vma->vm_flags & VM_HUGETLB) {
+		page = follow_huge_pmd(mm, ctx->address, pmd, ctx->flags);
 		if (page)
 			return page;
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 	}
 	if (is_hugepd(__hugepd(pmd_val(pmdval)))) {
-		page = follow_huge_pd(vma, address,
-				      __hugepd(pmd_val(pmdval)), flags,
-				      PMD_SHIFT);
+		page = follow_huge_pd(ctx->vma, ctx->address,
+				      __hugepd(pmd_val(pmdval)),
+				      ctx->flags, PGDIR_SHIFT);
 		if (page)
 			return page;
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 	}
 retry:
 	if (!pmd_present(pmdval)) {
-		if (likely(!(flags & FOLL_MIGRATION)))
-			return no_page_table(vma, flags);
+		if (likely(!(ctx->flags & FOLL_MIGRATION)))
+			return no_page_table(ctx);
 		VM_BUG_ON(thp_migration_supported() &&
 				  !is_pmd_migration_entry(pmdval));
 		if (is_pmd_migration_entry(pmdval))
@@ -253,46 +249,46 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 		 * mmap_sem is held in read mode
 		 */
 		if (pmd_none(pmdval))
-			return no_page_table(vma, flags);
+			return no_page_table(ctx);
 		goto retry;
 	}
 	if (pmd_devmap(pmdval)) {
 		ptl = pmd_lock(mm, pmd);
-		page = follow_devmap_pmd(vma, address, pmd, flags);
+		page = follow_devmap_pmd(ctx, pmd);
 		spin_unlock(ptl);
 		if (page)
 			return page;
 	}
 	if (likely(!pmd_trans_huge(pmdval)))
-		return follow_page_pte(vma, address, pmd, flags);
+		return follow_page_pte(ctx, pmd);
 
-	if ((flags & FOLL_NUMA) && pmd_protnone(pmdval))
-		return no_page_table(vma, flags);
+	if ((ctx->flags & FOLL_NUMA) && pmd_protnone(pmdval))
+		return no_page_table(ctx);
 
 retry_locked:
 	ptl = pmd_lock(mm, pmd);
 	if (unlikely(pmd_none(*pmd))) {
 		spin_unlock(ptl);
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 	}
 	if (unlikely(!pmd_present(*pmd))) {
 		spin_unlock(ptl);
-		if (likely(!(flags & FOLL_MIGRATION)))
-			return no_page_table(vma, flags);
+		if (likely(!(ctx->flags & FOLL_MIGRATION)))
+			return no_page_table(ctx);
 		pmd_migration_entry_wait(mm, pmd);
 		goto retry_locked;
 	}
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
-		return follow_page_pte(vma, address, pmd, flags);
+		return follow_page_pte(ctx, pmd);
 	}
-	if (flags & FOLL_SPLIT) {
+	if (ctx->flags & FOLL_SPLIT) {
 		int ret;
 		page = pmd_page(*pmd);
 		if (is_huge_zero_page(page)) {
 			spin_unlock(ptl);
 			ret = 0;
-			split_huge_pmd(vma, pmd, address);
+			split_huge_pmd(ctx->vma, pmd, ctx->address);
 			if (pmd_trans_unstable(pmd))
 				ret = -EBUSY;
 		} else {
@@ -303,82 +299,76 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			unlock_page(page);
 			put_page(page);
 			if (pmd_none(*pmd))
-				return no_page_table(vma, flags);
+				return no_page_table(ctx);
 		}
 
 		return ret ? ERR_PTR(ret) :
-			follow_page_pte(vma, address, pmd, flags);
+			follow_page_pte(ctx, pmd);
 	}
-	page = follow_trans_huge_pmd(vma, address, pmd, flags);
+	page = follow_trans_huge_pmd(ctx->vma, ctx->address, pmd, ctx->flags);
 	spin_unlock(ptl);
-	*page_mask = HPAGE_PMD_NR - 1;
+	ctx->page_mask = HPAGE_PMD_NR - 1;
 	return page;
 }
 
-
-static struct page *follow_pud_mask(struct vm_area_struct *vma,
-				    unsigned long address, p4d_t *p4dp,
-				    unsigned int flags, unsigned int *page_mask)
+static struct page *follow_pud_mask(struct follow_page_context *ctx, p4d_t *p4dp)
 {
 	pud_t *pud;
 	spinlock_t *ptl;
 	struct page *page;
-	struct mm_struct *mm = vma->vm_mm;
+	struct mm_struct *mm = ctx->vma->vm_mm;
 
-	pud = pud_offset(p4dp, address);
+	pud = pud_offset(p4dp, ctx->address);
 	if (pud_none(*pud))
-		return no_page_table(vma, flags);
-	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
-		page = follow_huge_pud(mm, address, pud, flags);
+		return no_page_table(ctx);
+	if (pud_huge(*pud) && ctx->vma->vm_flags & VM_HUGETLB) {
+		page = follow_huge_pud(mm, ctx->address, pud, ctx->flags);
 		if (page)
 			return page;
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 	}
 	if (is_hugepd(__hugepd(pud_val(*pud)))) {
-		page = follow_huge_pd(vma, address,
-				      __hugepd(pud_val(*pud)), flags,
-				      PUD_SHIFT);
+		page = follow_huge_pd(ctx->vma, ctx->address,
+				      __hugepd(pud_val(*pud)),
+				      ctx->flags, PUD_SHIFT);
 		if (page)
 			return page;
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 	}
 	if (pud_devmap(*pud)) {
 		ptl = pud_lock(mm, pud);
-		page = follow_devmap_pud(vma, address, pud, flags);
+		page = follow_devmap_pud(ctx, pud);
 		spin_unlock(ptl);
 		if (page)
 			return page;
 	}
 	if (unlikely(pud_bad(*pud)))
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 
-	return follow_pmd_mask(vma, address, pud, flags, page_mask);
+	return follow_pmd_mask(ctx, pud);
 }
 
-
-static struct page *follow_p4d_mask(struct vm_area_struct *vma,
-				    unsigned long address, pgd_t *pgdp,
-				    unsigned int flags, unsigned int *page_mask)
+static struct page *follow_p4d_mask(struct follow_page_context *ctx, pgd_t *pgdp)
 {
 	p4d_t *p4d;
 	struct page *page;
 
-	p4d = p4d_offset(pgdp, address);
+	p4d = p4d_offset(pgdp, ctx->address);
 	if (p4d_none(*p4d))
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 	BUILD_BUG_ON(p4d_huge(*p4d));
 	if (unlikely(p4d_bad(*p4d)))
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 
 	if (is_hugepd(__hugepd(p4d_val(*p4d)))) {
-		page = follow_huge_pd(vma, address,
-				      __hugepd(p4d_val(*p4d)), flags,
-				      P4D_SHIFT);
+		page = follow_huge_pd(ctx->vma, ctx->address,
+				      __hugepd(p4d_val(*p4d)),
+				      ctx->flags, P4D_SHIFT);
 		if (page)
 			return page;
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 	}
-	return follow_pud_mask(vma, address, p4d, flags, page_mask);
+	return follow_pud_mask(ctx, p4d);
 }
 
 /**
@@ -394,44 +384,40 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
  * an error pointer if there is a mapping to something not represented
  * by a page descriptor (see also vm_normal_page()).
  */
-struct page *follow_page_mask(struct vm_area_struct *vma,
-			      unsigned long address, unsigned int flags,
-			      unsigned int *page_mask)
+struct page *follow_page_mask(struct follow_page_context *ctx)
 {
 	pgd_t *pgd;
 	struct page *page;
-	struct mm_struct *mm = vma->vm_mm;
-
-	*page_mask = 0;
+	struct mm_struct *mm = ctx->vma->vm_mm;
 
 	/* make this handle hugepd */
-	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
+	page = follow_huge_addr(mm, ctx->address, ctx->flags & FOLL_WRITE);
 	if (!IS_ERR(page)) {
-		BUG_ON(flags & FOLL_GET);
+		BUG_ON(ctx->flags & FOLL_GET);
 		return page;
 	}
 
-	pgd = pgd_offset(mm, address);
+	pgd = pgd_offset(mm, ctx->address);
 
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 
 	if (pgd_huge(*pgd)) {
-		page = follow_huge_pgd(mm, address, pgd, flags);
+		page = follow_huge_pgd(mm, ctx->address, pgd, ctx->flags);
 		if (page)
 			return page;
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 	}
 	if (is_hugepd(__hugepd(pgd_val(*pgd)))) {
-		page = follow_huge_pd(vma, address,
-				      __hugepd(pgd_val(*pgd)), flags,
-				      PGDIR_SHIFT);
+		page = follow_huge_pd(ctx->vma, ctx->address,
+				      __hugepd(pgd_val(*pgd)),
+				      ctx->flags, PGDIR_SHIFT);
 		if (page)
 			return page;
-		return no_page_table(vma, flags);
+		return no_page_table(ctx);
 	}
 
-	return follow_p4d_mask(vma, address, pgd, flags, page_mask);
+	return follow_p4d_mask(ctx, pgd);
 }
 
 static int get_gate_page(struct mm_struct *mm, unsigned long address,
@@ -493,31 +479,31 @@ static int get_gate_page(struct mm_struct *mm, unsigned long address,
  * *@flags does not include FOLL_NOWAIT, the mmap_sem may be released.
  * If it is, *@nonblocking will be set to 0 and -EBUSY returned.
  */
-static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
-		unsigned long address, unsigned int *flags, int *nonblocking)
+static int faultin_page(struct task_struct *tsk, struct follow_page_context *ctx,
+		int *nonblocking)
 {
 	unsigned int fault_flags = 0;
 	vm_fault_t ret;
 
 	/* mlock all present pages, but do not fault in new pages */
-	if ((*flags & (FOLL_POPULATE | FOLL_MLOCK)) == FOLL_MLOCK)
+	if ((ctx->flags & (FOLL_POPULATE | FOLL_MLOCK)) == FOLL_MLOCK)
 		return -ENOENT;
-	if (*flags & FOLL_WRITE)
+	if (ctx->flags & FOLL_WRITE)
 		fault_flags |= FAULT_FLAG_WRITE;
-	if (*flags & FOLL_REMOTE)
+	if (ctx->flags & FOLL_REMOTE)
 		fault_flags |= FAULT_FLAG_REMOTE;
 	if (nonblocking)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
-	if (*flags & FOLL_NOWAIT)
+	if (ctx->flags & FOLL_NOWAIT)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
-	if (*flags & FOLL_TRIED) {
+	if (ctx->flags & FOLL_TRIED) {
 		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
-	ret = handle_mm_fault(vma, address, fault_flags);
+	ret = handle_mm_fault(ctx->vma, ctx->address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
-		int err = vm_fault_to_errno(ret, *flags);
+		int err = vm_fault_to_errno(ret, ctx->flags);
 
 		if (err)
 			return err;
@@ -546,8 +532,8 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	 * which a read fault here might prevent (a readonly page might get
 	 * reCOWed by userspace write).
 	 */
-	if ((ret & VM_FAULT_WRITE) && !(vma->vm_flags & VM_WRITE))
-		*flags |= FOLL_COW;
+	if ((ret & VM_FAULT_WRITE) && !(ctx->vma->vm_flags & VM_WRITE))
+		ctx->flags |= FOLL_COW;
 	return 0;
 }
 
@@ -660,8 +646,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		struct vm_area_struct **vmas, int *nonblocking)
 {
 	long i = 0;
-	unsigned int page_mask;
 	struct vm_area_struct *vma = NULL;
+	struct follow_page_context ctx = {};
 
 	if (!nr_pages)
 		return 0;
@@ -676,9 +662,9 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!(gup_flags & FOLL_FORCE))
 		gup_flags |= FOLL_NUMA;
 
+	ctx.flags = gup_flags;
 	do {
 		struct page *page;
-		unsigned int foll_flags = gup_flags;
 		unsigned int page_increm;
 
 		/* first iteration or cross vma bound */
@@ -691,7 +677,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 						pages ? &pages[i] : NULL);
 				if (ret)
 					return i ? : ret;
-				page_mask = 0;
+				ctx.page_mask = 0;
 				goto next_page;
 			}
 
@@ -704,6 +690,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				continue;
 			}
 		}
+		ctx.vma = vma;
+		ctx.address = start;
 retry:
 		/*
 		 * If we have a pending SIGKILL, don't keep faulting pages and
@@ -712,11 +700,11 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		if (unlikely(fatal_signal_pending(current)))
 			return i ? i : -ERESTARTSYS;
 		cond_resched();
-		page = follow_page_mask(vma, start, foll_flags, &page_mask);
+
+		page = follow_page_mask(&ctx);
 		if (!page) {
 			int ret;
-			ret = faultin_page(tsk, vma, start, &foll_flags,
-					nonblocking);
+			ret = faultin_page(tsk, &ctx, nonblocking);
 			switch (ret) {
 			case 0:
 				goto retry;
@@ -743,14 +731,14 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			pages[i] = page;
 			flush_anon_page(vma, page, start);
 			flush_dcache_page(page);
-			page_mask = 0;
+			ctx.page_mask = 0;
 		}
 next_page:
 		if (vmas) {
 			vmas[i] = vma;
-			page_mask = 0;
+			ctx.page_mask = 0;
 		}
-		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
+		page_increm = 1 + (~(start >> PAGE_SHIFT) & ctx.page_mask);
 		if (page_increm > nr_pages)
 			page_increm = nr_pages;
 		i += page_increm;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 533f9b00147d..abd36e6afe2c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -851,11 +851,10 @@ static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
 		update_mmu_cache_pmd(vma, addr, pmd);
 }
 
-struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, int flags)
+struct page *follow_devmap_pmd(struct follow_page_context *ctx, pmd_t *pmd)
 {
 	unsigned long pfn = pmd_pfn(*pmd);
-	struct mm_struct *mm = vma->vm_mm;
+	struct mm_struct *mm = ctx->vma->vm_mm;
 	struct dev_pagemap *pgmap;
 	struct page *page;
 
@@ -865,9 +864,9 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 	 * When we COW a devmap PMD entry, we split it into PTEs, so we should
 	 * not be in this function with `flags & FOLL_COW` set.
 	 */
-	WARN_ONCE(flags & FOLL_COW, "mm: In follow_devmap_pmd with FOLL_COW set");
+	WARN_ONCE(ctx->flags & FOLL_COW, "mm: In follow_devmap_pmd with FOLL_COW set");
 
-	if (flags & FOLL_WRITE && !pmd_write(*pmd))
+	if (ctx->flags & FOLL_WRITE && !pmd_write(*pmd))
 		return NULL;
 
 	if (pmd_present(*pmd) && pmd_devmap(*pmd))
@@ -875,17 +874,17 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 	else
 		return NULL;
 
-	if (flags & FOLL_TOUCH)
-		touch_pmd(vma, addr, pmd, flags);
+	if (ctx->flags & FOLL_TOUCH)
+		touch_pmd(ctx->vma, ctx->address, pmd, ctx->flags);
 
 	/*
 	 * device mapped pages can only be returned if the
 	 * caller will manage the page reference count.
 	 */
-	if (!(flags & FOLL_GET))
+	if (!(ctx->flags & FOLL_GET))
 		return ERR_PTR(-EEXIST);
 
-	pfn += (addr & ~PMD_MASK) >> PAGE_SHIFT;
+	pfn += (ctx->address & ~PMD_MASK) >> PAGE_SHIFT;
 	pgmap = get_dev_pagemap(pfn, NULL);
 	if (!pgmap)
 		return ERR_PTR(-EFAULT);
@@ -999,17 +998,16 @@ static void touch_pud(struct vm_area_struct *vma, unsigned long addr,
 		update_mmu_cache_pud(vma, addr, pud);
 }
 
-struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
-		pud_t *pud, int flags)
+struct page *follow_devmap_pud(struct follow_page_context *ctx, pud_t *pud)
 {
 	unsigned long pfn = pud_pfn(*pud);
-	struct mm_struct *mm = vma->vm_mm;
+	struct mm_struct *mm = ctx->vma->vm_mm;
 	struct dev_pagemap *pgmap;
 	struct page *page;
 
 	assert_spin_locked(pud_lockptr(mm, pud));
 
-	if (flags & FOLL_WRITE && !pud_write(*pud))
+	if (ctx->flags & FOLL_WRITE && !pud_write(*pud))
 		return NULL;
 
 	if (pud_present(*pud) && pud_devmap(*pud))
@@ -1017,17 +1015,17 @@ struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 	else
 		return NULL;
 
-	if (flags & FOLL_TOUCH)
-		touch_pud(vma, addr, pud, flags);
+	if (ctx->flags & FOLL_TOUCH)
+		touch_pud(ctx->vma, ctx->address, pud, ctx->flags);
 
 	/*
 	 * device mapped pages can only be returned if the
 	 * caller will manage the page reference count.
 	 */
-	if (!(flags & FOLL_GET))
+	if (!(ctx->flags & FOLL_GET))
 		return ERR_PTR(-EEXIST);
 
-	pfn += (addr & ~PUD_MASK) >> PAGE_SHIFT;
+	pfn += (ctx->address & ~PUD_MASK) >> PAGE_SHIFT;
 	pgmap = get_dev_pagemap(pfn, NULL);
 	if (!pgmap)
 		return ERR_PTR(-EFAULT);
diff --git a/mm/nommu.c b/mm/nommu.c
index e4aac33216ae..59db9f5dbb4e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1709,11 +1709,9 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	return ret;
 }
 
-struct page *follow_page_mask(struct vm_area_struct *vma,
-			      unsigned long address, unsigned int flags,
-			      unsigned int *page_mask)
+struct page *follow_page_mask(struct follow_page_context *ctx)
 {
-	*page_mask = 0;
+	ctx->page_mask = 0;
 	return NULL;
 }
 
-- 
2.14.4
