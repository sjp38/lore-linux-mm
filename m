Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE276B0038
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 05:07:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f193so5903459wmg.3
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 02:07:43 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id h5si3769199wjj.224.2016.10.15.02.07.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Oct 2016 02:07:41 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id z189so1777911wmb.1
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 02:07:41 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH] mm/vmalloc: Replace opencoded 4-level page walkers
Date: Sat, 15 Oct 2016 10:07:31 +0100
Message-Id: <20161015090731.14878-1-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Rather than open-code the intricacies of walking the 4-level page
tables, use the generic page table walker apply_to_page_range() instead.

There is a slight loss in functionality when unmapping as we now walk
all pages within the range rather than skipping over empty directories.
In theory, we should not be unmapping any pages that we ourselves didn't
successfully map. On the other hand, it now cleans up after an
unsuccessful insertion and propagates the correct error. The current
failure may lead to a WARN if we encounter ENOMEM in one
vmap_pte_range() and later retry with the same page range.

WARNING: CPU: 0 PID: 605 at mm/vmalloc.c:136 vmap_page_range_noflush+0x2c1/0x340
i.e. WARN_ON(!pte_none(*pte))

References: https://bugs.freedesktop.org/show_bug.cgi?id=98269
Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: Jerome Marchand <jmarchan@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org
---
 mm/vmalloc.c | 150 +++++++++++++----------------------------------------------
 1 file changed, 33 insertions(+), 117 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 91f44e78c516..e18cea62fea6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -59,121 +59,40 @@ static void free_work(struct work_struct *w)
 
 /*** Page table manipulation functions ***/
 
-static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
+static int vunmap_page(pte_t *pte, pgtable_t token,
+		       unsigned long addr, void *data)
 {
-	pte_t *pte;
-
-	pte = pte_offset_kernel(pmd, addr);
-	do {
-		pte_t ptent = ptep_get_and_clear(&init_mm, addr, pte);
-		WARN_ON(!pte_none(ptent) && !pte_present(ptent));
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-}
-
-static void vunmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_clear_huge(pmd))
-			continue;
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		vunmap_pte_range(pmd, addr, next);
-	} while (pmd++, addr = next, addr != end);
-}
-
-static void vunmap_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_clear_huge(pud))
-			continue;
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		vunmap_pmd_range(pud, addr, next);
-	} while (pud++, addr = next, addr != end);
+	pte_t ptent = ptep_get_and_clear(&init_mm, addr, pte);
+	WARN_ON(!pte_none(ptent) && !pte_present(ptent));
+	return 0;
 }
 
 static void vunmap_page_range(unsigned long addr, unsigned long end)
 {
-	pgd_t *pgd;
-	unsigned long next;
-
-	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		vunmap_pud_range(pgd, addr, next);
-	} while (pgd++, addr = next, addr != end);
+	apply_to_page_range(&init_mm, addr, end - addr, vunmap_page, NULL);
 }
 
-static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
-{
-	pte_t *pte;
-
-	/*
-	 * nr is a running index into the array which helps higher level
-	 * callers keep track of where we're up to.
-	 */
-
-	pte = pte_alloc_kernel(pmd, addr);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		struct page *page = pages[*nr];
-
-		if (WARN_ON(!pte_none(*pte)))
-			return -EBUSY;
-		if (WARN_ON(!page))
-			return -ENOMEM;
-		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
-		(*nr)++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	return 0;
-}
+struct vmap_page {
+	pgprot_t prot;
+	struct page **pages;
+	unsigned long count;
+};
 
-static int vmap_pmd_range(pud_t *pud, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+static int vmap_page(pte_t *pte, pgtable_t token,
+		     unsigned long addr, void *data)
 {
-	pmd_t *pmd;
-	unsigned long next;
+	struct vmap_page *v = data;
+	struct page *page;
 
-	pmd = pmd_alloc(&init_mm, pud, addr);
-	if (!pmd)
-		return -ENOMEM;
-	do {
-		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
-			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
-	return 0;
-}
+	if (WARN_ON(!pte_none(*pte)))
+		return -EBUSY;
 
-static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_alloc(&init_mm, pgd, addr);
-	if (!pud)
+	page = v->pages[v->count];
+	if (WARN_ON(!page))
 		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
+
+	set_pte_at(&init_mm, addr, pte, mk_pte(page, v->prot));
+	v->count++;
 	return 0;
 }
 
@@ -186,22 +105,19 @@ static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
 static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 				   pgprot_t prot, struct page **pages)
 {
-	pgd_t *pgd;
-	unsigned long next;
-	unsigned long addr = start;
-	int err = 0;
-	int nr = 0;
+	struct vmap_page v = { prot, pages };
+	int err;
 
-	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = vmap_pud_range(pgd, addr, next, prot, pages, &nr);
-		if (err)
-			return err;
-	} while (pgd++, addr = next, addr != end);
+	if ((end - start) >> PAGE_SHIFT > INT_MAX)
+		return -EINVAL;
+
+	err = apply_to_page_range(&init_mm, start, end - start, vmap_page, &v);
+	if (unlikely(err)) {
+		vunmap_page_range(start, start + (v.count << PAGE_SHIFT));
+		return err;
+	}
 
-	return nr;
+	return v.count;
 }
 
 static int vmap_page_range(unsigned long start, unsigned long end,
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
