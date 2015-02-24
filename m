Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 754A16B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 14:54:20 -0500 (EST)
Received: by pdjy10 with SMTP id y10so35678457pdj.6
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 11:54:20 -0800 (PST)
Received: from mail-gw2-out.broadcom.com (mail-gw2-out.broadcom.com. [216.31.210.63])
        by mx.google.com with ESMTP id nq6si6786849pbc.101.2015.02.24.11.54.18
        for <linux-mm@kvack.org>;
        Tue, 24 Feb 2015 11:54:19 -0800 (PST)
From: Danesh Petigara <dpetigara@broadcom.com>
Subject: [PATCH] mm: cma: fix CMA aligned offset calculation
Date: Tue, 24 Feb 2015 11:55:59 -0800
Message-ID: <1424807759-23311-1-git-send-email-dpetigara@broadcom.com>
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
---
 mm/cma.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 75016fd..58f37bd 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -70,9 +70,13 @@ static unsigned long cma_bitmap_aligned_offset(struct cma *cma, int align_order)
 
 	if (align_order <= cma->order_per_bit)
 		return 0;
-	alignment = 1UL << (align_order - cma->order_per_bit);
-	return ALIGN(cma->base_pfn, alignment) -
-		(cma->base_pfn >> cma->order_per_bit);
+
+	/*
+	 * Find a PFN aligned to the specified order and return
+	 * an offset represented in order_per_bits.
+	 */
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
