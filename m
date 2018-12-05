Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4C96B7391
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:19:28 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p15so16291579pfk.7
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:19:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6sor27288241pfj.10.2018.12.05.01.19.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 01:19:27 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 2/2] mm, page_alloc: cleanup usemap_size() when SPARSEMEM is not set
Date: Wed,  5 Dec 2018 17:19:05 +0800
Message-Id: <20181205091905.27727-2-richard.weiyang@gmail.com>
In-Reply-To: <20181205091905.27727-1-richard.weiyang@gmail.com>
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@techsingularity.net, akpm@linux-foundation.org, Wei Yang <richard.weiyang@gmail.com>

Two cleanups in this patch:

  * since pageblock_nr_pages == (1 << pageblock_order), the roundup()
    and right shift pageblock_order could be replaced with
    DIV_ROUND_UP()
  * use BITS_TO_LONGS() to get number of bytes for bitmap

This patch also fix one typo in comment.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/page_alloc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7c745c305332..baf473f80800 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6204,7 +6204,7 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
 /*
  * Calculate the size of the zone->blockflags rounded to an unsigned long
  * Start by making sure zonesize is a multiple of pageblock_order by rounding
- * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
+ * up. Then use 1 NR_PAGEBLOCK_BITS width of bits per pageblock, finally
  * round what is now in bits to nearest long in bits, then return it in
  * bytes.
  */
@@ -6213,12 +6213,9 @@ static unsigned long __init usemap_size(unsigned long zone_start_pfn, unsigned l
 	unsigned long usemapsize;
 
 	zonesize += zone_start_pfn & (pageblock_nr_pages-1);
-	usemapsize = roundup(zonesize, pageblock_nr_pages);
-	usemapsize = usemapsize >> pageblock_order;
+	usemapsize = DIV_ROUND_UP(zonesize, pageblock_nr_pages);
 	usemapsize *= NR_PAGEBLOCK_BITS;
-	usemapsize = roundup(usemapsize, 8 * sizeof(unsigned long));
-
-	return usemapsize / 8;
+	return BITS_TO_LONGS(usemapsize) * sizeof(unsigned long);
 }
 
 static void __ref setup_usemap(struct pglist_data *pgdat,
-- 
2.15.1
