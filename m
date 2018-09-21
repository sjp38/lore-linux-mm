Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 933AB8E0025
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 18:40:09 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m4-v6so6129584pgq.19
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:40:09 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id u18-v6si28263356pfa.28.2018.09.21.15.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 15:40:07 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 6/6] mm/gup: Cache dev_pagemap while pinning pages
Date: Fri, 21 Sep 2018 16:39:56 -0600
Message-Id: <20180921223956.3485-7-keith.busch@intel.com>
In-Reply-To: <20180921223956.3485-1-keith.busch@intel.com>
References: <20180921223956.3485-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Pinning pages from ZONE_DEVICE memory needs to check the backing device's
live-ness, which is tracked in the device's dev_pagemap metadata. This
metadata is stored in a radix tree and looking it up adds measurable
software overhead.

This patch avoids repeating this relatively costly operation when
dev_pagemap is used by caching the last dev_pagemap when getting user
pages. The gup_benchmark reports this reduces the time to get user pages
to as low as 1/3 of the previous time.

The cached value is combined with other output parameters into a context
struct to keep the parameters fewer.

Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 include/linux/huge_mm.h |  8 ++---
 include/linux/mm.h      | 19 +++++++++--
 mm/gup.c                | 90 +++++++++++++++++++++++++++----------------------
 mm/huge_memory.c        | 38 +++++++++------------
 mm/nommu.c              |  4 +--
 5 files changed, 88 insertions(+), 71 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 99c19b06d9a4..5cbabdebe9af 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -213,9 +213,9 @@ static inline int hpage_nr_pages(struct page *page)
 }
 
 struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, int flags);
+		pmd_t *pmd, int flags, struct dev_pagemap **pgmap);
 struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
-		pud_t *pud, int flags);
+		pud_t *pud, int flags, struct dev_pagemap **pgmap);
 
 extern vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
@@ -344,13 +344,13 @@ static inline void mm_put_huge_zero_page(struct mm_struct *mm)
 }
 
 static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
-		unsigned long addr, pmd_t *pmd, int flags)
+	unsigned long addr, pmd_t *pmd, int flags, struct dev_pagemap **pgmap)
 {
 	return NULL;
 }
 
 static inline struct page *follow_devmap_pud(struct vm_area_struct *vma,
-		unsigned long addr, pud_t *pud, int flags)
+	unsigned long addr, pud_t *pud, int flags, struct dev_pagemap **pgmap)
 {
 	return NULL;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..79c80496dd50 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2534,15 +2534,28 @@ static inline vm_fault_t vmf_error(int err)
 	return VM_FAULT_SIGBUS;
 }
 
+struct follow_page_context {
+	struct dev_pagemap *pgmap;
+	unsigned int page_mask;
+};
+
 struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned long address, unsigned int foll_flags,
-			      unsigned int *page_mask);
+			      struct follow_page_context *ctx);
 
 static inline struct page *follow_page(struct vm_area_struct *vma,
 		unsigned long address, unsigned int foll_flags)
 {
-	unsigned int unused_page_mask;
-	return follow_page_mask(vma, address, foll_flags, &unused_page_mask);
+	struct page *page;
+	struct follow_page_context ctx = {
+		.pgmap = NULL,
+		.page_mask = 0,
+	};
+
+	page = follow_page_mask(vma, address, foll_flags, &ctx);
+	if (ctx.pgmap)
+		put_dev_pagemap(ctx.pgmap);
+	return page;
 }
 
 #define FOLL_WRITE	0x01	/* check pte is writable */
diff --git a/mm/gup.c b/mm/gup.c
index 1abc8b4afff6..124e7293e381 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -71,10 +71,10 @@ static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
 }
 
 static struct page *follow_page_pte(struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd, unsigned int flags)
+		unsigned long address, pmd_t *pmd, unsigned int flags,
+		struct dev_pagemap **pgmap)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	struct dev_pagemap *pgmap = NULL;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t *ptep, pte;
@@ -116,8 +116,8 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		 * Only return device mapping pages in the FOLL_GET case since
 		 * they are only valid while holding the pgmap reference.
 		 */
-		pgmap = get_dev_pagemap(pte_pfn(pte), NULL);
-		if (pgmap)
+		*pgmap = get_dev_pagemap(pte_pfn(pte), *pgmap);
+		if (*pgmap)
 			page = pte_page(pte);
 		else
 			goto no_page;
@@ -156,9 +156,9 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 		get_page(page);
 
 		/* drop the pgmap reference now that we hold the page */
-		if (pgmap) {
-			put_dev_pagemap(pgmap);
-			pgmap = NULL;
+		if (*pgmap) {
+			put_dev_pagemap(*pgmap);
+			*pgmap = NULL;
 		}
 	}
 	if (flags & FOLL_TOUCH) {
@@ -210,7 +210,8 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 
 static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 				    unsigned long address, pud_t *pudp,
-				    unsigned int flags, unsigned int *page_mask)
+				    unsigned int flags,
+				    struct follow_page_context *ctx)
 {
 	pmd_t *pmd, pmdval;
 	spinlock_t *ptl;
@@ -258,13 +259,13 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	}
 	if (pmd_devmap(pmdval)) {
 		ptl = pmd_lock(mm, pmd);
-		page = follow_devmap_pmd(vma, address, pmd, flags);
+		page = follow_devmap_pmd(vma, address, pmd, flags, &ctx->pgmap);
 		spin_unlock(ptl);
 		if (page)
 			return page;
 	}
 	if (likely(!pmd_trans_huge(pmdval)))
-		return follow_page_pte(vma, address, pmd, flags);
+		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
 
 	if ((flags & FOLL_NUMA) && pmd_protnone(pmdval))
 		return no_page_table(vma, flags);
@@ -284,7 +285,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	}
 	if (unlikely(!pmd_trans_huge(*pmd))) {
 		spin_unlock(ptl);
-		return follow_page_pte(vma, address, pmd, flags);
+		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
 	}
 	if (flags & FOLL_SPLIT) {
 		int ret;
@@ -307,18 +308,18 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 		}
 
 		return ret ? ERR_PTR(ret) :
-			follow_page_pte(vma, address, pmd, flags);
+			follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
 	}
 	page = follow_trans_huge_pmd(vma, address, pmd, flags);
 	spin_unlock(ptl);
-	*page_mask = HPAGE_PMD_NR - 1;
+	ctx->page_mask = HPAGE_PMD_NR - 1;
 	return page;
 }
 
-
 static struct page *follow_pud_mask(struct vm_area_struct *vma,
 				    unsigned long address, p4d_t *p4dp,
-				    unsigned int flags, unsigned int *page_mask)
+				    unsigned int flags,
+				    struct follow_page_context *ctx)
 {
 	pud_t *pud;
 	spinlock_t *ptl;
@@ -344,7 +345,7 @@ static struct page *follow_pud_mask(struct vm_area_struct *vma,
 	}
 	if (pud_devmap(*pud)) {
 		ptl = pud_lock(mm, pud);
-		page = follow_devmap_pud(vma, address, pud, flags);
+		page = follow_devmap_pud(vma, address, pud, flags, &ctx->pgmap);
 		spin_unlock(ptl);
 		if (page)
 			return page;
@@ -352,13 +353,13 @@ static struct page *follow_pud_mask(struct vm_area_struct *vma,
 	if (unlikely(pud_bad(*pud)))
 		return no_page_table(vma, flags);
 
-	return follow_pmd_mask(vma, address, pud, flags, page_mask);
+	return follow_pmd_mask(vma, address, pud, flags, ctx);
 }
 
-
 static struct page *follow_p4d_mask(struct vm_area_struct *vma,
 				    unsigned long address, pgd_t *pgdp,
-				    unsigned int flags, unsigned int *page_mask)
+				    unsigned int flags,
+				    struct follow_page_context *ctx)
 {
 	p4d_t *p4d;
 	struct page *page;
@@ -378,7 +379,7 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
 			return page;
 		return no_page_table(vma, flags);
 	}
-	return follow_pud_mask(vma, address, p4d, flags, page_mask);
+	return follow_pud_mask(vma, address, p4d, flags, ctx);
 }
 
 /**
@@ -396,13 +397,13 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
  */
 struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned long address, unsigned int flags,
-			      unsigned int *page_mask)
+			      struct follow_page_context *ctx)
 {
 	pgd_t *pgd;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 
-	*page_mask = 0;
+	ctx->page_mask = 0;
 
 	/* make this handle hugepd */
 	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
@@ -431,7 +432,7 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 		return no_page_table(vma, flags);
 	}
 
-	return follow_p4d_mask(vma, address, pgd, flags, page_mask);
+	return follow_p4d_mask(vma, address, pgd, flags, ctx);
 }
 
 static int get_gate_page(struct mm_struct *mm, unsigned long address,
@@ -659,9 +660,9 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas, int *nonblocking)
 {
-	long i = 0;
-	unsigned int page_mask;
+	long ret = 0, i = 0;
 	struct vm_area_struct *vma = NULL;
+	struct follow_page_context ctx = {};
 
 	if (!nr_pages)
 		return 0;
@@ -691,12 +692,14 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 						pages ? &pages[i] : NULL);
 				if (ret)
 					return i ? : ret;
-				page_mask = 0;
+				ctx.page_mask = 0;
 				goto next_page;
 			}
 
-			if (!vma || check_vma_flags(vma, gup_flags))
-				return i ? : -EFAULT;
+			if (!vma || check_vma_flags(vma, gup_flags)) {
+				ret = -EFAULT;
+				goto out;
+			}
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
@@ -709,23 +712,26 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		 * If we have a pending SIGKILL, don't keep faulting pages and
 		 * potentially allocating memory.
 		 */
-		if (unlikely(fatal_signal_pending(current)))
-			return i ? i : -ERESTARTSYS;
+		if (unlikely(fatal_signal_pending(current))) {
+			ret = -ERESTARTSYS;
+			goto out;
+		}
 		cond_resched();
-		page = follow_page_mask(vma, start, foll_flags, &page_mask);
+
+		page = follow_page_mask(vma, start, foll_flags, &ctx);
 		if (!page) {
-			int ret;
 			ret = faultin_page(tsk, vma, start, &foll_flags,
 					nonblocking);
 			switch (ret) {
 			case 0:
 				goto retry;
+			case -EBUSY:
+				ret = 0;
+				/* FALLTHRU */
 			case -EFAULT:
 			case -ENOMEM:
 			case -EHWPOISON:
-				return i ? i : ret;
-			case -EBUSY:
-				return i;
+				goto out;
 			case -ENOENT:
 				goto next_page;
 			}
@@ -737,27 +743,31 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			 */
 			goto next_page;
 		} else if (IS_ERR(page)) {
-			return i ? i : PTR_ERR(page);
+			ret = PTR_ERR(page);
+			goto out;
 		}
 		if (pages) {
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
 		start += page_increm * PAGE_SIZE;
 		nr_pages -= page_increm;
 	} while (nr_pages);
-	return i;
+out:
+	if (ctx.pgmap)
+		put_dev_pagemap(ctx.pgmap);
+	return i ? i : ret;
 }
 
 static bool vma_permits_fault(struct vm_area_struct *vma,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 533f9b00147d..9839bf91b057 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -851,13 +851,23 @@ static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
 		update_mmu_cache_pmd(vma, addr, pmd);
 }
 
+static struct page *pagemap_page(unsigned long pfn, struct dev_pagemap **pgmap)
+{
+	struct page *page;
+
+	*pgmap = get_dev_pagemap(pfn, *pgmap);
+	if (!*pgmap)
+		return ERR_PTR(-EFAULT);
+	page = pfn_to_page(pfn);
+	get_page(page);
+	return page;
+}
+
 struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
-		pmd_t *pmd, int flags)
+		pmd_t *pmd, int flags, struct dev_pagemap **pgmap)
 {
 	unsigned long pfn = pmd_pfn(*pmd);
 	struct mm_struct *mm = vma->vm_mm;
-	struct dev_pagemap *pgmap;
-	struct page *page;
 
 	assert_spin_locked(pmd_lockptr(mm, pmd));
 
@@ -886,14 +896,7 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 		return ERR_PTR(-EEXIST);
 
 	pfn += (addr & ~PMD_MASK) >> PAGE_SHIFT;
-	pgmap = get_dev_pagemap(pfn, NULL);
-	if (!pgmap)
-		return ERR_PTR(-EFAULT);
-	page = pfn_to_page(pfn);
-	get_page(page);
-	put_dev_pagemap(pgmap);
-
-	return page;
+	return pagemap_page(pfn, pgmap);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
@@ -1000,12 +1003,10 @@ static void touch_pud(struct vm_area_struct *vma, unsigned long addr,
 }
 
 struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
-		pud_t *pud, int flags)
+               pud_t *pud, int flags, struct dev_pagemap **pgmap)
 {
 	unsigned long pfn = pud_pfn(*pud);
 	struct mm_struct *mm = vma->vm_mm;
-	struct dev_pagemap *pgmap;
-	struct page *page;
 
 	assert_spin_locked(pud_lockptr(mm, pud));
 
@@ -1028,14 +1029,7 @@ struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 		return ERR_PTR(-EEXIST);
 
 	pfn += (addr & ~PUD_MASK) >> PAGE_SHIFT;
-	pgmap = get_dev_pagemap(pfn, NULL);
-	if (!pgmap)
-		return ERR_PTR(-EFAULT);
-	page = pfn_to_page(pfn);
-	get_page(page);
-	put_dev_pagemap(pgmap);
-
-	return page;
+	return pagemap_page(pfn, pgmap);
 }
 
 int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
diff --git a/mm/nommu.c b/mm/nommu.c
index e4aac33216ae..a795c70cf21e 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1711,9 +1711,9 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 
 struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned long address, unsigned int flags,
-			      unsigned int *page_mask)
+			      struct follow_page_context *ctx)
 {
-	*page_mask = 0;
+	ctx->page_mask = 0;
 	return NULL;
 }
 
-- 
2.14.4
