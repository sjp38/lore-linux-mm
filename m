Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD9E6B0032
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 03:57:39 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so28984745pab.1
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 00:57:39 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id li10si7047140pbc.154.2015.02.28.00.57.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 00:57:38 -0800 (PST)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: cma: constify and use correct signness in mm/cma.c
Date: Sat, 28 Feb 2015 03:57:22 -0500
Message-Id: <1425113842-11694-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

Constify function parameters and use correct signness where needed.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/cma.h |   12 ++++++------
 mm/cma.c            |   24 ++++++++++++++----------
 2 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index 9384ba6..f7ef093 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -16,16 +16,16 @@
 struct cma;
 
 extern unsigned long totalcma_pages;
-extern phys_addr_t cma_get_base(struct cma *cma);
-extern unsigned long cma_get_size(struct cma *cma);
+extern phys_addr_t cma_get_base(const struct cma *cma);
+extern unsigned long cma_get_size(const struct cma *cma);
 
 extern int __init cma_declare_contiguous(phys_addr_t base,
 			phys_addr_t size, phys_addr_t limit,
 			phys_addr_t alignment, unsigned int order_per_bit,
 			bool fixed, struct cma **res_cma);
-extern int cma_init_reserved_mem(phys_addr_t base,
-					phys_addr_t size, int order_per_bit,
+extern int cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
+					unsigned int order_per_bit,
 					struct cma **res_cma);
-extern struct page *cma_alloc(struct cma *cma, int count, unsigned int align);
-extern bool cma_release(struct cma *cma, struct page *pages, int count);
+extern struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align);
+extern bool cma_release(struct cma *cma, const struct page *pages, unsigned int count);
 #endif
diff --git a/mm/cma.c b/mm/cma.c
index a85ae28..ec1a84e 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -47,24 +47,26 @@ static struct cma cma_areas[MAX_CMA_AREAS];
 static unsigned cma_area_count;
 static DEFINE_MUTEX(cma_mutex);
 
-phys_addr_t cma_get_base(struct cma *cma)
+phys_addr_t cma_get_base(const struct cma *cma)
 {
 	return PFN_PHYS(cma->base_pfn);
 }
 
-unsigned long cma_get_size(struct cma *cma)
+unsigned long cma_get_size(const struct cma *cma)
 {
 	return cma->count << PAGE_SHIFT;
 }
 
-static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
+static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
+						unsigned int align_order)
 {
 	if (align_order <= cma->order_per_bit)
 		return 0;
 	return (1UL << (align_order - cma->order_per_bit)) - 1;
 }
 
-static unsigned long cma_bitmap_aligned_offset(struct cma *cma, int align_order)
+static unsigned long cma_bitmap_aligned_offset(const struct cma *cma,
+						unsigned int align_order)
 {
 	unsigned int alignment;
 
@@ -75,18 +77,19 @@ static unsigned long cma_bitmap_aligned_offset(struct cma *cma, int align_order)
 		(cma->base_pfn >> cma->order_per_bit);
 }
 
-static unsigned long cma_bitmap_maxno(struct cma *cma)
+static unsigned long cma_bitmap_maxno(const struct cma *cma)
 {
 	return cma->count >> cma->order_per_bit;
 }
 
-static unsigned long cma_bitmap_pages_to_bits(struct cma *cma,
+static unsigned long cma_bitmap_pages_to_bits(const struct cma *cma,
 						unsigned long pages)
 {
 	return ALIGN(pages, 1UL << cma->order_per_bit) >> cma->order_per_bit;
 }
 
-static void cma_clear_bitmap(struct cma *cma, unsigned long pfn, int count)
+static void cma_clear_bitmap(struct cma *cma, unsigned long pfn,
+				unsigned int count)
 {
 	unsigned long bitmap_no, bitmap_count;
 
@@ -165,7 +168,8 @@ core_initcall(cma_init_reserved_areas);
  * This function creates custom contiguous area from already reserved memory.
  */
 int __init cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
-				 int order_per_bit, struct cma **res_cma)
+					unsigned int order_per_bit,
+				 	struct cma **res_cma)
 {
 	struct cma *cma;
 	phys_addr_t alignment;
@@ -356,7 +360,7 @@ err:
  * This function allocates part of contiguous memory on specific
  * contiguous memory area.
  */
-struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
+struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align)
 {
 	unsigned long mask, offset, pfn, start = 0;
 	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
@@ -427,7 +431,7 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
  * It returns false when provided pages do not belong to contiguous area and
  * true otherwise.
  */
-bool cma_release(struct cma *cma, struct page *pages, int count)
+bool cma_release(struct cma *cma, const struct page *pages, unsigned int count)
 {
 	unsigned long pfn;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
