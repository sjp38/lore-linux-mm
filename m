Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFBA6B0253
	for <linux-mm@kvack.org>; Thu,  5 May 2016 03:57:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 4so154754708pfw.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:57:40 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id ef2si9913151pac.119.2016.05.05.00.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 00:57:39 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id yl2so7341687pac.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 00:57:39 -0700 (PDT)
From: Oliver O'Halloran <oohall@gmail.com>
Subject: [RFC PATCH] mm/init: fix zone boundary creation
Date: Thu,  5 May 2016 17:57:13 +1000
Message-Id: <1462435033-15601-1-git-send-email-oohall@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Oliver O'Halloran <oohall@gmail.com>, linuxppc-dev@lists.ozlabs.org

As a part of memory initialisation the architecture passes an array to
free_area_init_nodes() which specifies the max PFN of each memory zone.
This array is not necessarily monotonic (due to unused zones) so this
array is parsed to build monotonic lists of the min and max PFN for
each zone. ZONE_MOVABLE is special cased here as its limits are managed by
the mm subsystem rather than the architecture. Unfortunately, this special
casing is broken when ZONE_MOVABLE is the not the last zone in the zone
list. The core of the issue is:

	if (i == ZONE_MOVABLE)
		continue;
	arch_zone_lowest_possible_pfn[i] =
		arch_zone_highest_possible_pfn[i-1];

As ZONE_MOVABLE is skipped the lowest_possible_pfn of the next zone
will be set to zero. This patch fixes this bug by adding explicitly
tracking where the next zone should start rather than relying on the
contents arch_zone_highest_possible_pfn[].

Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org
---
 mm/page_alloc.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 59de90d5d3a3..fc78306ce087 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5980,15 +5980,18 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 				sizeof(arch_zone_lowest_possible_pfn));
 	memset(arch_zone_highest_possible_pfn, 0,
 				sizeof(arch_zone_highest_possible_pfn));
-	arch_zone_lowest_possible_pfn[0] = find_min_pfn_with_active_regions();
-	arch_zone_highest_possible_pfn[0] = max_zone_pfn[0];
-	for (i = 1; i < MAX_NR_ZONES; i++) {
+
+	start_pfn = find_min_pfn_with_active_regions();
+
+	for (i = 0; i < MAX_NR_ZONES; i++) {
 		if (i == ZONE_MOVABLE)
 			continue;
-		arch_zone_lowest_possible_pfn[i] =
-			arch_zone_highest_possible_pfn[i-1];
-		arch_zone_highest_possible_pfn[i] =
-			max(max_zone_pfn[i], arch_zone_lowest_possible_pfn[i]);
+
+		end_pfn = max(max_zone_pfn[i], start_pfn);
+		arch_zone_lowest_possible_pfn[i] = start_pfn;
+		arch_zone_highest_possible_pfn[i] = end_pfn;
+
+		start_pfn = end_pfn;
 	}
 	arch_zone_lowest_possible_pfn[ZONE_MOVABLE] = 0;
 	arch_zone_highest_possible_pfn[ZONE_MOVABLE] = 0;
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
