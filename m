Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8BF6B003A
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:36:44 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id md12so3246220pbc.33
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:36:43 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id bs8si12413683pad.157.2014.06.15.22.36.41
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:36:42 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 -next 4/9] DMA, CMA: support arbitrary bitmap granularity
Date: Mon, 16 Jun 2014 14:40:46 +0900
Message-Id: <1402897251-23639-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

PPC KVM's CMA area management requires arbitrary bitmap granularity,
since they want to reserve very large memory and manage this region
with bitmap that one bit for several pages to reduce management overheads.
So support arbitrary bitmap granularity for following generalization.

v3: use consistent local variable name (Minchan)
    use unsigned int for order_per_bit (Michal)
    change clear_cma_bitmap to cma_clear_bitmap for consistency (Michal)
    remove un-needed local variable, bitmap_maxno (Michal)

Acked-by: Michal Nazarewicz <mina86@mina86.com>
Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 5f62c28..c6eeb2c 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -38,6 +38,7 @@ struct cma {
 	unsigned long	base_pfn;
 	unsigned long	count;
 	unsigned long	*bitmap;
+	unsigned int order_per_bit; /* Order of pages represented by one bit */
 	struct mutex	lock;
 };
 
@@ -157,9 +158,37 @@ void __init dma_contiguous_reserve(phys_addr_t limit)
 
 static DEFINE_MUTEX(cma_mutex);
 
+static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
+{
+	return (1 << (align_order >> cma->order_per_bit)) - 1;
+}
+
+static unsigned long cma_bitmap_maxno(struct cma *cma)
+{
+	return cma->count >> cma->order_per_bit;
+}
+
+static unsigned long cma_bitmap_pages_to_bits(struct cma *cma,
+						unsigned long pages)
+{
+	return ALIGN(pages, 1 << cma->order_per_bit) >> cma->order_per_bit;
+}
+
+static void cma_clear_bitmap(struct cma *cma, unsigned long pfn, int count)
+{
+	unsigned long bitmap_no, bitmap_count;
+
+	bitmap_no = (pfn - cma->base_pfn) >> cma->order_per_bit;
+	bitmap_count = cma_bitmap_pages_to_bits(cma, count);
+
+	mutex_lock(&cma->lock);
+	bitmap_clear(cma->bitmap, bitmap_no, bitmap_count);
+	mutex_unlock(&cma->lock);
+}
+
 static int __init cma_activate_area(struct cma *cma)
 {
-	int bitmap_size = BITS_TO_LONGS(cma->count) * sizeof(long);
+	int bitmap_size = BITS_TO_LONGS(cma_bitmap_maxno(cma)) * sizeof(long);
 	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
 	unsigned i = cma->count >> pageblock_order;
 	struct zone *zone;
@@ -215,9 +244,9 @@ static int __init cma_init_reserved_areas(void)
 core_initcall(cma_init_reserved_areas);
 
 static int __init __dma_contiguous_reserve_area(phys_addr_t size,
-				phys_addr_t base, phys_addr_t limit,
-				phys_addr_t alignment,
-				struct cma **res_cma, bool fixed)
+			phys_addr_t base, phys_addr_t limit,
+			phys_addr_t alignment, unsigned int order_per_bit,
+			struct cma **res_cma, bool fixed)
 {
 	struct cma *cma = &cma_areas[cma_area_count];
 	int ret = 0;
@@ -249,6 +278,10 @@ static int __init __dma_contiguous_reserve_area(phys_addr_t size,
 	size = ALIGN(size, alignment);
 	limit &= ~(alignment - 1);
 
+	/* size should be aligned with order_per_bit */
+	if (!IS_ALIGNED(size >> PAGE_SHIFT, 1 << order_per_bit))
+		return -EINVAL;
+
 	/* Reserve memory */
 	if (base && fixed) {
 		if (memblock_is_region_reserved(base, size) ||
@@ -273,6 +306,7 @@ static int __init __dma_contiguous_reserve_area(phys_addr_t size,
 	 */
 	cma->base_pfn = PFN_DOWN(base);
 	cma->count = size >> PAGE_SHIFT;
+	cma->order_per_bit = order_per_bit;
 	*res_cma = cma;
 	cma_area_count++;
 
@@ -308,7 +342,7 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
 {
 	int ret;
 
-	ret = __dma_contiguous_reserve_area(size, base, limit, 0,
+	ret = __dma_contiguous_reserve_area(size, base, limit, 0, 0,
 						res_cma, fixed);
 	if (ret)
 		return ret;
@@ -320,17 +354,11 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
 	return 0;
 }
 
-static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
-{
-	mutex_lock(&cma->lock);
-	bitmap_clear(cma->bitmap, pfn - cma->base_pfn, count);
-	mutex_unlock(&cma->lock);
-}
-
 static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
 				       unsigned int align)
 {
-	unsigned long mask, pfn, pageno, start = 0;
+	unsigned long mask, pfn, start = 0;
+	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
 	struct page *page = NULL;
 	int ret;
 
@@ -343,18 +371,19 @@ static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
 	if (!count)
 		return NULL;
 
-	mask = (1 << align) - 1;
-
+	mask = cma_bitmap_aligned_mask(cma, align);
+	bitmap_maxno = cma_bitmap_maxno(cma);
+	bitmap_count = cma_bitmap_pages_to_bits(cma, count);
 
 	for (;;) {
 		mutex_lock(&cma->lock);
-		pageno = bitmap_find_next_zero_area(cma->bitmap, cma->count,
-						    start, count, mask);
-		if (pageno >= cma->count) {
+		bitmap_no = bitmap_find_next_zero_area(cma->bitmap,
+				bitmap_maxno, start, bitmap_count, mask);
+		if (bitmap_no >= bitmap_maxno) {
 			mutex_unlock(&cma->lock);
 			break;
 		}
-		bitmap_set(cma->bitmap, pageno, count);
+		bitmap_set(cma->bitmap, bitmap_no, bitmap_count);
 		/*
 		 * It's safe to drop the lock here. We've marked this region for
 		 * our exclusive use. If the migration fails we will take the
@@ -362,7 +391,7 @@ static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
 		 */
 		mutex_unlock(&cma->lock);
 
-		pfn = cma->base_pfn + pageno;
+		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
 		mutex_lock(&cma_mutex);
 		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
 		mutex_unlock(&cma_mutex);
@@ -370,14 +399,14 @@ static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
 			page = pfn_to_page(pfn);
 			break;
 		} else if (ret != -EBUSY) {
-			clear_cma_bitmap(cma, pfn, count);
+			cma_clear_bitmap(cma, pfn, count);
 			break;
 		}
-		clear_cma_bitmap(cma, pfn, count);
+		cma_clear_bitmap(cma, pfn, count);
 		pr_debug("%s(): memory range at %p is busy, retrying\n",
 			 __func__, pfn_to_page(pfn));
 		/* try again with a bit different memory target */
-		start = pageno + mask + 1;
+		start = bitmap_no + mask + 1;
 	}
 
 	pr_debug("%s(): returned %p\n", __func__, page);
@@ -424,7 +453,7 @@ static bool __dma_release_from_contiguous(struct cma *cma, struct page *pages,
 	VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
 
 	free_contig_range(pfn, count);
-	clear_cma_bitmap(cma, pfn, count);
+	cma_clear_bitmap(cma, pfn, count);
 
 	return true;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
