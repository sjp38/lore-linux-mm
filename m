Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 466398E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 18:49:29 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l76so8666305pfg.1
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 15:49:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b60sor8856829plc.24.2019.01.18.15.49.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 15:49:27 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, page_alloc: cleanup usemap_size() when SPARSEMEM is not set
Date: Sat, 19 Jan 2019 07:49:05 +0800
Message-Id: <20190118234905.27597-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, Wei Yang <richard.weiyang@gmail.com>

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
index d295c9bc01a8..d7073cedd087 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6352,7 +6352,7 @@ static void __init calculate_node_totalpages(struct pglist_data *pgdat,
 /*
  * Calculate the size of the zone->blockflags rounded to an unsigned long
  * Start by making sure zonesize is a multiple of pageblock_order by rounding
- * up. Then use 1 NR_PAGEBLOCK_BITS worth of bits per pageblock, finally
+ * up. Then use 1 NR_PAGEBLOCK_BITS width of bits per pageblock, finally
  * round what is now in bits to nearest long in bits, then return it in
  * bytes.
  */
@@ -6361,12 +6361,9 @@ static unsigned long __init usemap_size(unsigned long zone_start_pfn, unsigned l
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
