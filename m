Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 907108D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 16:04:09 -0500 (EST)
Received: by qwa26 with SMTP id 26so107894qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 13:04:06 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 21:04:06 +0000
Message-ID: <AANLkTikeoXcL6Up=0bL-zq13nHu7qPLye=Wjh3z4Z9sW@mail.gmail.com>
Subject: [RFC][PATCH 21/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f9b1667..908c7b6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -87,8 +87,8 @@ static void vunmap_page_range(unsigned long addr,
unsigned long end)
    } while (pgd++, addr = next, addr != end);
 }

-static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-       unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+static int vmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
+       pgprot_t prot, struct page **pages, int *nr, gfp_t gfp_mask)
 {
    pte_t *pte;

@@ -97,7 +97,7 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
     * callers keep track of where we're up to.
     */

-   pte = pte_alloc_kernel(pmd, addr);
+   pte = pte_alloc_kernel_with_mask(pmd, addr, gfp_mask);
    if (!pte)
        return -ENOMEM;
    do {
@@ -114,34 +114,35 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 }

 static int vmap_pmd_range(pud_t *pud, unsigned long addr,
-       unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+       unsigned long end, pgprot_t prot, struct page **pages, int
*nr, gfp_t gfp_mask)
 {
    pmd_t *pmd;
    unsigned long next;

-   pmd = pmd_alloc(&init_mm, pud, addr);
+   pmd = pmd_alloc_with_mask(&init_mm, pud, addr, gfp_mask);
    if (!pmd)
        return -ENOMEM;
    do {
        next = pmd_addr_end(addr, end);
-       if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
+       /* XXX TODO */
+       if (vmap_pte_range(pmd, addr, next, prot, pages, nr, gfp_mask))
            return -ENOMEM;
    } while (pmd++, addr = next, addr != end);
    return 0;
 }

-static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-       unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+static int vmap_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
+       pgprot_t prot, struct page **pages, int *nr, gfp_t gfp_mask)
 {
    pud_t *pud;
    unsigned long next;

-   pud = pud_alloc(&init_mm, pgd, addr);
+   pud = pud_alloc_with_mask(&init_mm, pgd, addr, gfp_mask);
    if (!pud)
        return -ENOMEM;
    do {
        next = pud_addr_end(addr, end);
-       if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
+       if (vmap_pmd_range(pud, addr, next, prot, pages, nr, gfp_mask))
            return -ENOMEM;
    } while (pud++, addr = next, addr != end);
    return 0;
@@ -153,8 +154,8 @@ static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
  *
  * Ie. pte at addr+N*PAGE_SIZE shall point to pfn corresponding to pages[N]
  */
-static int vmap_page_range_noflush(unsigned long start, unsigned long end,
-                  pgprot_t prot, struct page **pages)
+static int __vmap_page_range_noflush(unsigned long start, unsigned long end,
+                  pgprot_t prot, struct page **pages, gfp_t gfp_mask)
 {
    pgd_t *pgd;
    unsigned long next;
@@ -166,7 +167,7 @@ static int vmap_page_range_noflush(unsigned long
start, unsigned long end,
    pgd = pgd_offset_k(addr);
    do {
        next = pgd_addr_end(addr, end);
-       err = vmap_pud_range(pgd, addr, next, prot, pages, &nr);
+       err = vmap_pud_range(pgd, addr, next, prot, pages, &nr, gfp_mask);
        if (err)
            return err;
    } while (pgd++, addr = next, addr != end);
@@ -174,16 +175,29 @@ static int vmap_page_range_noflush(unsigned long
start, unsigned long end,
    return nr;
 }

-static int vmap_page_range(unsigned long start, unsigned long end,
-              pgprot_t prot, struct page **pages)
+
+static int vmap_page_range_noflush(unsigned long start, unsigned long end,
+                  pgprot_t prot, struct page **pages)
+{
+   return __vmap_page_range_noflush(start, end, prot, pages, GFP_KERNEL);
+}
+
+static int __vmap_page_range(unsigned long start, unsigned long end,
+              pgprot_t prot, struct page **pages, gfp_t gfp_mask)
 {
    int ret;

-   ret = vmap_page_range_noflush(start, end, prot, pages);
+   ret = __vmap_page_range_noflush(start, end, prot, pages, gfp_mask);
    flush_cache_vmap(start, end);
    return ret;
 }

+static int vmap_page_range(unsigned long start, unsigned long end,
+              pgprot_t prot, struct page **pages)
+{
+   return __vmap_page_range(start, end, prot, pages, GFP_KERNEL);
+}
+
 int is_vmalloc_or_module_addr(const void *x)
 {
    /*
@@ -1194,13 +1208,14 @@ void unmap_kernel_range(unsigned long addr,
unsigned long size)
    flush_tlb_kernel_range(addr, end);
 }

-int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+int __map_vm_area(struct vm_struct *area, pgprot_t prot,
+       struct page ***pages, gfp_t gfp_mask)
 {
    unsigned long addr = (unsigned long)area->addr;
    unsigned long end = addr + area->size - PAGE_SIZE;
    int err;

-   err = vmap_page_range(addr, end, prot, *pages);
+   err = __vmap_page_range(addr, end, prot, *pages, gfp_mask);
    if (err > 0) {
        *pages += err;
        err = 0;
@@ -1208,6 +1223,11 @@ int map_vm_area(struct vm_struct *area,
pgprot_t prot, struct page ***pages)

    return err;
 }
+
+int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+{
+   return __map_vm_area(area, prot, pages, GFP_KERNEL);
+}
 EXPORT_SYMBOL_GPL(map_vm_area);

 /*** Old vmalloc interfaces ***/
@@ -1522,7 +1542,7 @@ static void *__vmalloc_area_node(struct
vm_struct *area, gfp_t gfp_mask,
        area->pages[i] = page;
    }

-   if (map_vm_area(area, prot, &pages))
+   if (__map_vm_area(area, prot, &pages, gfp_mask))
        goto fail;
    return area->addr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
