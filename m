Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA166B0037
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:45:35 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so14332440pad.9
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:45:35 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id ov6si35523052pdb.237.2014.08.21.01.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 21 Aug 2014 01:45:34 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAN009BHF4J7X70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 21 Aug 2014 09:48:19 +0100 (BST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 1/2] mm: cma: adjust address limit to avoid hitting low/high
 memory boundary
Date: Thu, 21 Aug 2014 10:45:13 +0200
Message-id: <1408610714-16204-2-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

Automatically allocated regions should not cross low/high memory boundary,
because such regions cannot be later correctly initialized due to spanning
across two memory zones. This patch adds a check for this case and a simple
code for moving region to low memory if automatically selected address might
not fit completely into high memory.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 mm/cma.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index c17751c0dcaf..4acc6aa4a086 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -32,6 +32,7 @@
 #include <linux/slab.h>
 #include <linux/log2.h>
 #include <linux/cma.h>
+#include <linux/highmem.h>
 
 struct cma {
 	unsigned long	base_pfn;
@@ -163,6 +164,8 @@ int __init cma_declare_contiguous(phys_addr_t base,
 			bool fixed, struct cma **res_cma)
 {
 	struct cma *cma;
+	phys_addr_t memblock_end = memblock_end_of_DRAM();
+	phys_addr_t highmem_start = __pa(high_memory);
 	int ret = 0;
 
 	pr_debug("%s(size %lx, base %08lx, limit %08lx alignment %08lx)\n",
@@ -196,6 +199,24 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	if (!IS_ALIGNED(size >> PAGE_SHIFT, 1 << order_per_bit))
 		return -EINVAL;
 
+	/*
+	 * adjust limit to avoid crossing low/high memory boundary for
+	 * automatically allocated regions
+	 */
+	if (((limit == 0 || limit > memblock_end) &&
+	     (memblock_end - size < highmem_start &&
+	      memblock_end > highmem_start)) ||
+	    (!fixed && limit > highmem_start && limit - size < highmem_start)) {
+		limit = highmem_start;
+	}
+
+	if (fixed && base < highmem_start && base+size > highmem_start) {
+		ret = -EINVAL;
+		pr_err("Region at %08lx defined on low/high memory boundary (%08lx)\n",
+			(unsigned long)base, (unsigned long)highmem_start);
+		goto err;
+	}
+
 	/* Reserve memory */
 	if (base && fixed) {
 		if (memblock_is_region_reserved(base, size) ||
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
