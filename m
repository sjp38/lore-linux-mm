Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1C16B02D5
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 17:03:20 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id s144so568421oih.5
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 14:03:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x52si945488otb.218.2017.11.07.14.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 14:03:18 -0800 (PST)
Date: Tue, 7 Nov 2017 17:03:11 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] vmalloc: introduce vmap_pfn for persistent memory
Message-ID: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>
Cc: dm-devel@redhat.com, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@lst.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Hi

I am developing a driver that uses persistent memory for caching. A 
persistent memory device can be mapped in several discontiguous ranges.

The kernel has a function vmap that takes an array of pointers to pages 
and maps these pages to contiguous linear address space. However, it can't 
be used on persistent memory because persistent memory may not be backed 
by page structures.

This patch introduces a new function vmap_pfn, it works like vmap, but 
takes an array of pfn_t - so it can be used on persistent memory.

This is an example how vmap_pfn is used: 
https://www.redhat.com/archives/dm-devel/2017-November/msg00026.html (see 
the function persistent_memory_claim)

Mikulas



From: Mikulas Patocka <mpatocka@redhat.com>

There's a function vmap that can take discontiguous pages and map them 
linearly to the vmalloc space. However, persistent memory may not be 
backed by pages, so we can't use vmap on it.

This patch introduces a function vmap_pfn that works like vmap, but it 
takes an array of page frame numbers (pfn_t). It can be used to remap 
discontiguous chunks of persistent memory into a linear range.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 include/linux/vmalloc.h |    2 +
 mm/vmalloc.c            |   88 +++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 71 insertions(+), 19 deletions(-)

Index: linux-2.6/include/linux/vmalloc.h
===================================================================
--- linux-2.6.orig/include/linux/vmalloc.h
+++ linux-2.6/include/linux/vmalloc.h
@@ -98,6 +98,8 @@ extern void vfree_atomic(const void *add
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
+extern void *vmap_pfn(pfn_t *pfns, unsigned int count,
+			unsigned long flags, pgprot_t prot);
 extern void vunmap(const void *addr);
 
 extern int remap_vmalloc_range_partial(struct vm_area_struct *vma,
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c
+++ linux-2.6/mm/vmalloc.c
@@ -31,6 +31,7 @@
 #include <linux/compiler.h>
 #include <linux/llist.h>
 #include <linux/bitops.h>
+#include <linux/pfn_t.h>
 
 #include <linux/uaccess.h>
 #include <asm/tlbflush.h>
@@ -132,7 +133,7 @@ static void vunmap_page_range(unsigned l
 }
 
 static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+		unsigned long end, pgprot_t prot, struct page **pages, pfn_t *pfns, int *nr)
 {
 	pte_t *pte;
 
@@ -145,20 +146,25 @@ static int vmap_pte_range(pmd_t *pmd, un
 	if (!pte)
 		return -ENOMEM;
 	do {
-		struct page *page = pages[*nr];
-
+		unsigned long pf;
+		if (pages) {
+			struct page *page = pages[*nr];
+			if (WARN_ON(!page))
+				return -ENOMEM;
+			pf = page_to_pfn(page);
+		} else {
+			pf = pfn_t_to_pfn(pfns[*nr]);
+		}
 		if (WARN_ON(!pte_none(*pte)))
 			return -EBUSY;
-		if (WARN_ON(!page))
-			return -ENOMEM;
-		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
+		set_pte_at(&init_mm, addr, pte, pfn_pte(pf, prot));
 		(*nr)++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	return 0;
 }
 
 static int vmap_pmd_range(pud_t *pud, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+		unsigned long end, pgprot_t prot, struct page **pages, pfn_t *pfns, int *nr)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -168,14 +174,14 @@ static int vmap_pmd_range(pud_t *pud, un
 		return -ENOMEM;
 	do {
 		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
+		if (vmap_pte_range(pmd, addr, next, prot, pages, pfns, nr))
 			return -ENOMEM;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
 static int vmap_pud_range(p4d_t *p4d, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+		unsigned long end, pgprot_t prot, struct page **pages, pfn_t *pfns, int *nr)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -185,14 +191,14 @@ static int vmap_pud_range(p4d_t *p4d, un
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
+		if (vmap_pmd_range(pud, addr, next, prot, pages, pfns, nr))
 			return -ENOMEM;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
 static int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+		unsigned long end, pgprot_t prot, struct page **pages, pfn_t *pfns, int *nr)
 {
 	p4d_t *p4d;
 	unsigned long next;
@@ -202,7 +208,7 @@ static int vmap_p4d_range(pgd_t *pgd, un
 		return -ENOMEM;
 	do {
 		next = p4d_addr_end(addr, end);
-		if (vmap_pud_range(p4d, addr, next, prot, pages, nr))
+		if (vmap_pud_range(p4d, addr, next, prot, pages, pfns, nr))
 			return -ENOMEM;
 	} while (p4d++, addr = next, addr != end);
 	return 0;
@@ -215,7 +221,7 @@ static int vmap_p4d_range(pgd_t *pgd, un
  * Ie. pte at addr+N*PAGE_SIZE shall point to pfn corresponding to pages[N]
  */
 static int vmap_page_range_noflush(unsigned long start, unsigned long end,
-				   pgprot_t prot, struct page **pages)
+				   pgprot_t prot, struct page **pages, pfn_t *pfns)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -227,7 +233,7 @@ static int vmap_page_range_noflush(unsig
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = vmap_p4d_range(pgd, addr, next, prot, pages, &nr);
+		err = vmap_p4d_range(pgd, addr, next, prot, pages, pfns, &nr);
 		if (err)
 			return err;
 	} while (pgd++, addr = next, addr != end);
@@ -236,11 +242,11 @@ static int vmap_page_range_noflush(unsig
 }
 
 static int vmap_page_range(unsigned long start, unsigned long end,
-			   pgprot_t prot, struct page **pages)
+			   pgprot_t prot, struct page **pages, pfn_t *pfns)
 {
 	int ret;
 
-	ret = vmap_page_range_noflush(start, end, prot, pages);
+	ret = vmap_page_range_noflush(start, end, prot, pages, pfns);
 	flush_cache_vmap(start, end);
 	return ret;
 }
@@ -1191,7 +1197,7 @@ void *vm_map_ram(struct page **pages, un
 		addr = va->va_start;
 		mem = (void *)addr;
 	}
-	if (vmap_page_range(addr, addr + size, prot, pages) < 0) {
+	if (vmap_page_range(addr, addr + size, prot, pages, NULL) < 0) {
 		vm_unmap_ram(mem, count);
 		return NULL;
 	}
@@ -1306,7 +1312,7 @@ void __init vmalloc_init(void)
 int map_kernel_range_noflush(unsigned long addr, unsigned long size,
 			     pgprot_t prot, struct page **pages)
 {
-	return vmap_page_range_noflush(addr, addr + size, prot, pages);
+	return vmap_page_range_noflush(addr, addr + size, prot, pages, NULL);
 }
 
 /**
@@ -1347,13 +1353,24 @@ void unmap_kernel_range(unsigned long ad
 }
 EXPORT_SYMBOL_GPL(unmap_kernel_range);
 
+static int map_vm_area_pfn(struct vm_struct *area, pgprot_t prot, pfn_t *pfns)
+{
+	unsigned long addr = (unsigned long)area->addr;
+	unsigned long end = addr + get_vm_area_size(area);
+	int err;
+
+	err = vmap_page_range(addr, end, prot, NULL, pfns);
+
+	return err > 0 ? 0 : err;
+}
+
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page **pages)
 {
 	unsigned long addr = (unsigned long)area->addr;
 	unsigned long end = addr + get_vm_area_size(area);
 	int err;
 
-	err = vmap_page_range(addr, end, prot, pages);
+	err = vmap_page_range(addr, end, prot, pages, NULL);
 
 	return err > 0 ? 0 : err;
 }
@@ -1660,6 +1677,39 @@ void *vmap(struct page **pages, unsigned
 }
 EXPORT_SYMBOL(vmap);
 
+/**
+ *	vmap_pfn  -  map an array of pages into virtually contiguous space
+ *	@pfns:		array of page frame numbers
+ *	@count:		number of pages to map
+ *	@flags:		vm_area->flags
+ *	@prot:		page protection for the mapping
+ *
+ *	Maps @count pages from @pages into contiguous kernel virtual
+ *	space.
+ */
+void *vmap_pfn(pfn_t *pfns, unsigned int count, unsigned long flags, pgprot_t prot)
+{
+	struct vm_struct *area;
+	unsigned long size;		/* In bytes */
+
+	might_sleep();
+
+	size = (unsigned long)count << PAGE_SHIFT;
+	if (unlikely((size >> PAGE_SHIFT) != count))
+		return NULL;
+	area = get_vm_area_caller(size, flags, __builtin_return_address(0));
+	if (!area)
+		return NULL;
+
+	if (map_vm_area_pfn(area, prot, pfns)) {
+		vunmap(area->addr);
+		return NULL;
+	}
+
+	return area->addr;
+}
+EXPORT_SYMBOL(vmap_pfn);
+
 static void *__vmalloc_node(unsigned long size, unsigned long align,
 			    gfp_t gfp_mask, pgprot_t prot,
 			    int node, const void *caller);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
