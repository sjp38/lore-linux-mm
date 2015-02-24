Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 667BF6B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 18:38:33 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so330637pdb.11
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:38:33 -0800 (PST)
Received: from mail-gw1-out.broadcom.com (mail-gw1-out.broadcom.com. [216.31.210.62])
        by mx.google.com with ESMTP id ns16si1139073pdb.39.2015.02.24.15.38.32
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 15:38:32 -0800 (PST)
From: Danesh Petigara <dpetigara@broadcom.com>
Subject: [PATCH v2] mm: cma: fix CMA aligned offset calculation
Date: Tue, 24 Feb 2015 15:39:45 -0800
Message-ID: <1424821185-16956-1-git-send-email-dpetigara@broadcom.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: m.szyprowski@samsung.com, mina86@mina86.com, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, laurent.pinchart+renesas@ideasonboard.com, gregory.0xf0@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Danesh Petigara <dpetigara@broadcom.com>, stable@vger.kernel.org

The CMA aligned offset calculation is incorrect for
non-zero order_per_bit values.

For example, if cma->order_per_bit=1, cma->base_pfn=
0x2f800000 and align_order=12, the function returns
a value of 0x17c00 instead of 0x400.

This patch fixes the CMA aligned offset calculation.

Cc: stable@vger.kernel.org
Signed-off-by: Danesh Petigara <dpetigara@broadcom.com>
Reviewed-by: Gregory Fong <gregory.0xf0@gmail.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
---
Changes since v1:
	- moved comment out of function
	- removed unused 'alignment' variable

v1: https://lkml.org/lkml/2015/2/24/598

 mm/cma.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 75016fd..68ecb7a 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -64,15 +64,17 @@ static unsigned long cma_bitmap_aligned_mask(struct cma *cma, int align_order)
 	return (1UL << (align_order - cma->order_per_bit)) - 1;
 }
 
+/*
+ * Find a PFN aligned to the specified order and return an offset represented in
+ * order_per_bits.
+ */
 static unsigned long cma_bitmap_aligned_offset(struct cma *cma, int align_order)
 {
-	unsigned int alignment;
-
 	if (align_order <= cma->order_per_bit)
 		return 0;
-	alignment = 1UL << (align_order - cma->order_per_bit);
-	return ALIGN(cma->base_pfn, alignment) -
-		(cma->base_pfn >> cma->order_per_bit);
+
+	return (ALIGN(cma->base_pfn, (1UL << align_order))
+		- cma->base_pfn) >> cma->order_per_bit;
 }
 
 static unsigned long cma_bitmap_maxno(struct cma *cma)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
