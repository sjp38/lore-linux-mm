Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7ABE86B003A
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:36:43 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ma3so4071156pbc.14
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:36:43 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gi3si12444875pac.49.2014.06.15.22.36.41
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:36:42 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 -next 3/9] DMA, CMA: support alignment constraint on CMA region
Date: Mon, 16 Jun 2014 14:40:45 +0900
Message-Id: <1402897251-23639-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

PPC KVM's CMA area management needs alignment constraint on
CMA region. So support it to prepare generalization of CMA area
management functionality.

Additionally, add some comments which tell us why alignment
constraint is needed on CMA region.

v3: fix wrongly spelled word, align_order->alignment (Minchan)
    clear code documentation by Minchan's comment (Minchan)

Acked-by: Michal Nazarewicz <mina86@mina86.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 9021762..5f62c28 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -32,6 +32,7 @@
 #include <linux/swap.h>
 #include <linux/mm_types.h>
 #include <linux/dma-contiguous.h>
+#include <linux/log2.h>
 
 struct cma {
 	unsigned long	base_pfn;
@@ -215,17 +216,16 @@ core_initcall(cma_init_reserved_areas);
 
 static int __init __dma_contiguous_reserve_area(phys_addr_t size,
 				phys_addr_t base, phys_addr_t limit,
+				phys_addr_t alignment,
 				struct cma **res_cma, bool fixed)
 {
 	struct cma *cma = &cma_areas[cma_area_count];
-	phys_addr_t alignment;
 	int ret = 0;
 
-	pr_debug("%s(size %lx, base %08lx, limit %08lx)\n", __func__,
-		 (unsigned long)size, (unsigned long)base,
-		 (unsigned long)limit);
+	pr_debug("%s(size %lx, base %08lx, limit %08lx alignment %08lx)\n",
+		__func__, (unsigned long)size, (unsigned long)base,
+		(unsigned long)limit, (unsigned long)alignment);
 
-	/* Sanity checks */
 	if (cma_area_count == ARRAY_SIZE(cma_areas)) {
 		pr_err("Not enough slots for CMA reserved regions!\n");
 		return -ENOSPC;
@@ -234,8 +234,17 @@ static int __init __dma_contiguous_reserve_area(phys_addr_t size,
 	if (!size)
 		return -EINVAL;
 
-	/* Sanitise input arguments */
-	alignment = PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order);
+	if (alignment && !is_power_of_2(alignment))
+		return -EINVAL;
+
+	/*
+	 * Sanitise input arguments.
+	 * Pages both ends in CMA area could be merged into adjacent unmovable
+	 * migratetype page by page allocator's buddy algorithm. In the case,
+	 * you couldn't get a contiguous memory, which is not what we want.
+	 */
+	alignment = max(alignment,
+		(phys_addr_t)PAGE_SIZE << max(MAX_ORDER - 1, pageblock_order));
 	base = ALIGN(base, alignment);
 	size = ALIGN(size, alignment);
 	limit &= ~(alignment - 1);
@@ -299,7 +308,8 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
 {
 	int ret;
 
-	ret = __dma_contiguous_reserve_area(size, base, limit, res_cma, fixed);
+	ret = __dma_contiguous_reserve_area(size, base, limit, 0,
+						res_cma, fixed);
 	if (ret)
 		return ret;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
