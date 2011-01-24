Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACA36B00E7
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 17:58:40 -0500 (EST)
From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH 6/9] vmalloc: use apply_to_page_range_batch() for vmap_page_range_noflush()
Date: Mon, 24 Jan 2011 14:56:04 -0800
Message-Id: <937b74f8d19f7e62d63d4e82c2cf21f3bd636d9e.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>, Xen-devel <xen-devel@lists.xensource.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
List-ID: <linux-mm.kvack.org>

From: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

There's no need to open-code it when there's a helpful utility
function.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
Cc: Nick Piggin <npiggin@kernel.dk>
---
 mm/vmalloc.c |   92 ++++++++++++++++++---------------------------------------
 1 files changed, 29 insertions(+), 63 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e99aa3b..cf4e705 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -53,63 +53,34 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 	apply_to_page_range_batch(&init_mm, addr, end - addr, vunmap_pte, NULL);
 }
 
-static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+struct vmap_data
 {
-	pte_t *pte;
+	struct page **pages;
+	unsigned index;
+	pgprot_t prot;
+};
 
-	/*
-	 * nr is a running index into the array which helps higher level
-	 * callers keep track of where we're up to.
-	 */
+static int vmap_pte(pte_t *pte, unsigned count,
+		    unsigned long addr, void *data)
+{
+	struct vmap_data *vmap = data;
 
-	pte = pte_alloc_kernel(pmd, addr);
-	if (!pte)
-		return -ENOMEM;
-	do {
-		struct page *page = pages[*nr];
+	while (count--) {
+		struct page *page = vmap->pages[vmap->index];
 
 		if (WARN_ON(!pte_none(*pte)))
 			return -EBUSY;
+
 		if (WARN_ON(!page))
 			return -ENOMEM;
-		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
-		(*nr)++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	return 0;
-}
 
-static int vmap_pmd_range(pud_t *pud, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
-{
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
+		set_pte_at(&init_mm, addr, pte, mk_pte(page, vmap->prot));
 
-static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
-{
-	pud_t *pud;
-	unsigned long next;
+		pte++;
+		addr += PAGE_SIZE;
+		vmap->index++;
+	}
 
-	pud = pud_alloc(&init_mm, pgd, addr);
-	if (!pud)
-		return -ENOMEM;
-	do {
-		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
-			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
@@ -122,22 +93,17 @@ static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
 static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 				   pgprot_t prot, struct page **pages)
 {
-	pgd_t *pgd;
-	unsigned long next;
-	unsigned long addr = start;
-	int err = 0;
-	int nr = 0;
-
-	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = vmap_pud_range(pgd, addr, next, prot, pages, &nr);
-		if (err)
-			return err;
-	} while (pgd++, addr = next, addr != end);
-
-	return nr;
+	int err;
+	struct vmap_data vmap = {
+		.pages = pages,
+		.index = 0,
+		.prot = prot
+	};
+	
+	err = apply_to_page_range_batch(&init_mm, start, end - start,
+					vmap_pte, &vmap);
+	
+	return err ? err : vmap.index;
 }
 
 static int vmap_page_range(unsigned long start, unsigned long end,
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
