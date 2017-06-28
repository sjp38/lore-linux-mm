Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 508346B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 13:08:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f17so28664140qte.13
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 10:08:20 -0700 (PDT)
Received: from mail-qk0-x242.google.com (mail-qk0-x242.google.com. [2607:f8b0:400d:c09::242])
        by mx.google.com with ESMTPS id l34si2447896qte.350.2017.06.28.10.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 10:08:19 -0700 (PDT)
Received: by mail-qk0-x242.google.com with SMTP id p21so8528289qke.0
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 10:08:19 -0700 (PDT)
From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH] cma: fix calculation of aligned offset
Date: Wed, 28 Jun 2017 10:07:41 -0700
Message-Id: <20170628170742.2895-1-opendmb@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gregory Fong <gregory.0xf0@gmail.com>
Cc: Doug Berger <opendmb@gmail.com>, Angus Clark <angus@angusclark.org>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lucas Stach <l.stach@pengutronix.de>, Catalin Marinas <catalin.marinas@arm.com>, Shiraz Hashim <shashim@codeaurora.org>, Jaewon Kim <jaewon31.kim@samsung.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

The align_offset parameter is used by bitmap_find_next_zero_area_off()
to represent the offset of map's base from the previous alignment
boundary; the function ensures that the returned index, plus the
align_offset, honors the specified align_mask.

The logic introduced by commit b5be83e308f7 ("mm: cma: align to
physical address, not CMA region position") has the cma driver
calculate the offset to the *next* alignment boundary.  In most cases,
the base alignment is greater than that specified when making
allocations, resulting in a zero offset whether we align up or down.
In the example given with the commit, the base alignment (8MB) was
half the requested alignment (16MB) so the math also happened to work
since the offset is 8MB in both directions.  However, when requesting
allocations with an alignment greater than twice that of the base,
the returned index would not be correctly aligned.

Also, the align_order arguments of cma_bitmap_aligned_mask() and
cma_bitmap_aligned_offset() should not be negative so the argument
type was made unsigned.

Fixes: b5be83e308f7 ("mm: cma: align to physical address, not CMA region position")
Signed-off-by: Angus Clark <angus@angusclark.org>
Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 mm/cma.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 978b4a1441ef..56a388eb0242 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -59,7 +59,7 @@ const char *cma_get_name(const struct cma *cma)
 }
 
 static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
-					     int align_order)
+					     unsigned int align_order)
 {
 	if (align_order <= cma->order_per_bit)
 		return 0;
@@ -67,17 +67,14 @@ static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
 }
 
 /*
- * Find a PFN aligned to the specified order and return an offset represented in
- * order_per_bits.
+ * Find the offset of the base PFN from the specified align_order.
+ * The value returned is represented in order_per_bits.
  */
 static unsigned long cma_bitmap_aligned_offset(const struct cma *cma,
-					       int align_order)
+					       unsigned int align_order)
 {
-	if (align_order <= cma->order_per_bit)
-		return 0;
-
-	return (ALIGN(cma->base_pfn, (1UL << align_order))
-		- cma->base_pfn) >> cma->order_per_bit;
+	return (cma->base_pfn & ((1UL << align_order) - 1))
+		>> cma->order_per_bit;
 }
 
 static unsigned long cma_bitmap_pages_to_bits(const struct cma *cma,
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
