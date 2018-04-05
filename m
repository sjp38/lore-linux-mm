Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEA3B6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 03:27:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o33-v6so15763875plb.16
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 00:27:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y72-v6sor2913700plh.63.2018.04.05.00.27.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 00:27:28 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH] mm/thp: don't count ZONE_MOVABLE as the target for freepage reserving
Date: Thu,  5 Apr 2018 16:27:16 +0900
Message-Id: <1522913236-15776-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

ZONE_MOVABLE only has movable pages so we don't need to keep enough
freepages to avoid or deal with fragmentation. So, don't count it.

This changes min_free_kbytes and thus min_watermark greatly
if ZONE_MOVABLE is used. It will make the user uses more memory.

o System
22GB ram, fakenuma, 2 nodes. 5 zones are used.

o Before
min_free_kbytes: 112640

zone_info (min_watermark):
Node 0, zone      DMA
        min      19
Node 0, zone    DMA32
        min      3778
Node 0, zone   Normal
        min      10191
Node 0, zone  Movable
        min      0
Node 0, zone   Device
        min      0
Node 1, zone      DMA
        min      0
Node 1, zone    DMA32
        min      0
Node 1, zone   Normal
        min      14043
Node 1, zone  Movable
        min      127
Node 1, zone   Device
        min      0

o After
min_free_kbytes: 90112

zone_info (min_watermark):
Node 0, zone      DMA
        min      15
Node 0, zone    DMA32
        min      3022
Node 0, zone   Normal
        min      8152
Node 0, zone  Movable
        min      0
Node 0, zone   Device
        min      0
Node 1, zone      DMA
        min      0
Node 1, zone    DMA32
        min      0
Node 1, zone   Normal
        min      11234
Node 1, zone  Movable
        min      102
Node 1, zone   Device
        min      0

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/khugepaged.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 5de1c6f..92dd4e6 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1880,8 +1880,16 @@ static void set_recommended_min_free_kbytes(void)
 	int nr_zones = 0;
 	unsigned long recommended_min;
 
-	for_each_populated_zone(zone)
+	for_each_populated_zone(zone) {
+		/*
+		 * We don't need to worry about fragmentation of
+		 * ZONE_MOVABLE since it only has movable pages.
+		 */
+		if (zone_idx(zone) > gfp_zone(GFP_USER))
+			continue;
+
 		nr_zones++;
+	}
 
 	/* Ensure 2 pageblocks are free to assist fragmentation avoidance */
 	recommended_min = pageblock_nr_pages * nr_zones * 2;
-- 
2.7.4
