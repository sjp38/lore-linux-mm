Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2C606B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 12:11:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g16so680321wmg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:11:24 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id y14si49530616wjd.198.2016.10.18.09.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 09:11:23 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id d199so164791wmd.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:11:23 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v2] mm/vmalloc: Replace opencoded 4-level page walkers
Date: Tue, 18 Oct 2016 17:11:17 +0100
Message-Id: <20161018161117.31198-1-chris@chris-wilson.co.uk>
In-Reply-To: <20161015090731.14878-1-chris@chris-wilson.co.uk>
References: <20161015090731.14878-1-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Rather than open-code the intricacies of walking the 4-level page
tables, use the generic page table walker apply_to_page_range() instead.

The important change is that it now cleans up after an
unsuccessful insertion and propagates the correct error. The current
failure may lead to a WARN if we encounter ENOMEM in one
vmap_pte_range() and later retry with the same page range.

WARNING: CPU: 0 PID: 605 at mm/vmalloc.c:136 vmap_page_range_noflush+0x2c1/0x340
i.e. WARN_ON(!pte_none(*pte))

v2: Don't convert the vunmap code over to apply_to_page_range() as it
may try to allocate during atomic sections, such as exiting a task:

[    9.837563]  [<ffffffff810519b0>] pte_alloc_one_kernel+0x10/0x20
[    9.837568]  [<ffffffff811a7486>] __pte_alloc_kernel+0x16/0xa0
[    9.837572]  [<ffffffff811aaa76>] apply_to_page_range+0x3f6/0x460
[    9.837576]  [<ffffffff811b8888>] free_unmap_vmap_area_noflush+0x28/0x40
[    9.837579]  [<ffffffff811b9dcd>] remove_vm_area+0x4d/0x60
[    9.837582]  [<ffffffff811b9e09>] __vunmap+0x29/0x130
[    9.837585]  [<ffffffff811b9f7d>] vfree+0x3d/0x90
[    9.837589]  [<ffffffff8107ace6>] put_task_stack+0x76/0x130

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
 mm/vmalloc.c | 93 ++++++++++++++++++------------------------------------------
 1 file changed, 27 insertions(+), 66 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f2481cb4e6b2..7e945c63c7ef 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -117,63 +117,27 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 	} while (pgd++, addr = next, addr != end);
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
-
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
+	struct vmap_page *v = data;
+	struct page *page;
 
-static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
-{
-	pud_t *pud;
-	unsigned long next;
+	if (WARN_ON(!pte_none(*pte)))
+		return -EBUSY;
 
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
 
@@ -186,22 +150,19 @@ static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
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
