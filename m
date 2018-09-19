Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFC048E0008
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 17:01:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g12-v6so3080188plo.1
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:01:08 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u10-v6si17660550pga.37.2018.09.19.14.01.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 14:01:04 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 7/7] mm/gup: Cache dev_pagemap while pinning pages
Date: Wed, 19 Sep 2018 15:02:50 -0600
Message-Id: <20180919210250.28858-8-keith.busch@intel.com>
In-Reply-To: <20180919210250.28858-1-keith.busch@intel.com>
References: <20180919210250.28858-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

This avoids a repeated costly radix tree lookup when dev_pagemap is
used.

Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 include/linux/mm.h |  8 +++++++-
 mm/gup.c           | 41 ++++++++++++++++++++++++-----------------
 mm/huge_memory.c   | 35 +++++++++++++++--------------------
 3 files changed, 46 insertions(+), 38 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f1fd241c9071..d688e18a19c4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -380,6 +380,7 @@ struct vm_fault {
 
 struct follow_page_context {
 	struct vm_area_struct *vma;
+	struct dev_pagemap *pgmap;
 	unsigned long address;
 	unsigned int page_mask;
 	unsigned int flags;
@@ -2546,14 +2547,19 @@ struct page *follow_page_mask(struct follow_page_context *ctx);
 static inline struct page *follow_page(struct vm_area_struct *vma,
 		unsigned long address, unsigned int foll_flags)
 {
+	struct page *page;
 	struct follow_page_context ctx = {
 		.vma = vma,
+		.pgmap = NULL,
 		.address = address,
 		.page_mask = 0,
 		.flags = foll_flags,
 	};
 
-	return follow_page_mask(&ctx);
+	page = follow_page_mask(&ctx);
+	if (ctx.pgmap)
+		put_dev_pagemap(ctx.pgmap);
+	return page;
 }
 
 #define FOLL_WRITE	0x01	/* check pte is writable */
diff --git a/mm/gup.c b/mm/gup.c
index a61a6874c80c..1565b79d883b 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -72,7 +72,6 @@ static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
 static struct page *follow_page_pte(struct follow_page_context *ctx, pmd_t *pmd)
 {
 	struct mm_struct *mm = ctx->vma->vm_mm;
-	struct dev_pagemap *pgmap = NULL;
 	struct page *page;
 	spinlock_t *ptl;
 	pte_t *ptep, pte;
@@ -114,8 +113,8 @@ static struct page *follow_page_pte(struct follow_page_context *ctx, pmd_t *pmd)
 		 * Only return device mapping pages in the FOLL_GET case since
 		 * they are only valid while holding the pgmap reference.
 		 */
-		pgmap = get_dev_pagemap(pte_pfn(pte), NULL);
-		if (pgmap)
+		ctx->pgmap = get_dev_pagemap(pte_pfn(pte), ctx->pgmap);
+		if (ctx->pgmap)
 			page = pte_page(pte);
 		else
 			goto no_page;
@@ -154,9 +153,9 @@ static struct page *follow_page_pte(struct follow_page_context *ctx, pmd_t *pmd)
 		get_page(page);
 
 		/* drop the pgmap reference now that we hold the page */
-		if (pgmap) {
-			put_dev_pagemap(pgmap);
-			pgmap = NULL;
+		if (ctx->pgmap) {
+			put_dev_pagemap(ctx->pgmap);
+			ctx->pgmap = NULL;
 		}
 	}
 	if (ctx->flags & FOLL_TOUCH) {
@@ -645,7 +644,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas, int *nonblocking)
 {
-	long i = 0;
+	long ret = 0, i = 0;
 	struct vm_area_struct *vma = NULL;
 	struct follow_page_context ctx = {};
 
@@ -681,8 +680,10 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
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
@@ -697,23 +698,25 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
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
 
 		page = follow_page_mask(&ctx);
 		if (!page) {
-			int ret;
 			ret = faultin_page(tsk, &ctx, nonblocking);
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
@@ -725,7 +728,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			 */
 			goto next_page;
 		} else if (IS_ERR(page)) {
-			return i ? i : PTR_ERR(page);
+			ret = PTR_ERR(page);
+			goto out;
 		}
 		if (pages) {
 			pages[i] = page;
@@ -745,7 +749,10 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
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
index abd36e6afe2c..6787011385ce 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -851,12 +851,23 @@ static void touch_pmd(struct vm_area_struct *vma, unsigned long addr,
 		update_mmu_cache_pmd(vma, addr, pmd);
 }
 
+static struct page *pagemap_page(struct follow_page_context *ctx,
+				 unsigned long pfn)
+{
+	struct page *page;
+
+	ctx->pgmap = get_dev_pagemap(pfn, ctx->pgmap);
+	if (!ctx->pgmap)
+		return ERR_PTR(-EFAULT);
+	page = pfn_to_page(pfn);
+	get_page(page);
+	return page;
+}
+
 struct page *follow_devmap_pmd(struct follow_page_context *ctx, pmd_t *pmd)
 {
 	unsigned long pfn = pmd_pfn(*pmd);
 	struct mm_struct *mm = ctx->vma->vm_mm;
-	struct dev_pagemap *pgmap;
-	struct page *page;
 
 	assert_spin_locked(pmd_lockptr(mm, pmd));
 
@@ -885,14 +896,7 @@ struct page *follow_devmap_pmd(struct follow_page_context *ctx, pmd_t *pmd)
 		return ERR_PTR(-EEXIST);
 
 	pfn += (ctx->address & ~PMD_MASK) >> PAGE_SHIFT;
-	pgmap = get_dev_pagemap(pfn, NULL);
-	if (!pgmap)
-		return ERR_PTR(-EFAULT);
-	page = pfn_to_page(pfn);
-	get_page(page);
-	put_dev_pagemap(pgmap);
-
-	return page;
+	return pagemap_page(ctx, pfn);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
@@ -1002,8 +1006,6 @@ struct page *follow_devmap_pud(struct follow_page_context *ctx, pud_t *pud)
 {
 	unsigned long pfn = pud_pfn(*pud);
 	struct mm_struct *mm = ctx->vma->vm_mm;
-	struct dev_pagemap *pgmap;
-	struct page *page;
 
 	assert_spin_locked(pud_lockptr(mm, pud));
 
@@ -1026,14 +1028,7 @@ struct page *follow_devmap_pud(struct follow_page_context *ctx, pud_t *pud)
 		return ERR_PTR(-EEXIST);
 
 	pfn += (ctx->address & ~PUD_MASK) >> PAGE_SHIFT;
-	pgmap = get_dev_pagemap(pfn, NULL);
-	if (!pgmap)
-		return ERR_PTR(-EFAULT);
-	page = pfn_to_page(pfn);
-	get_page(page);
-	put_dev_pagemap(pgmap);
-
-	return page;
+	return pagemap_page(ctx, pfn);
 }
 
 int copy_huge_pud(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-- 
2.14.4
