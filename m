Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3F3D6B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 22:22:01 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j8so69500051itb.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 19:22:01 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id t1si839529itb.59.2016.07.12.19.22.00
        for <linux-mm@kvack.org>;
        Tue, 12 Jul 2016 19:22:01 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm: fix calculation accounting dirtyable highmem
Date: Wed, 13 Jul 2016 11:23:13 +0900
Message-Id: <1468376593-26444-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

When I tested vmscale in mmtest in 32bit, I found the benchmark
was slow down 0.5 times.

                base        node
                   1    global-1
User           12.98       16.04
System        147.61      166.42
Elapsed        26.48       38.08

With vmstat, I found IO wait avg is much increased compared to
base.

The reason was highmem_dirtyable_memory accumulates free pages
and highmem_file_pages from HIGHMEM to MOVABLE zones which was
wrong. With that, dirth_thresh in throtlle_vm_write is always
0 so that it calls congestion_wait frequently if writeback
starts.

With this patch, it is much recovered.

                base        node          fi
                   1    global-1         fix
User           12.98       16.04       13.78
System        147.61      166.42      143.92
Elapsed        26.48       38.08       29.64

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page-writeback.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 8db1db2..bf27594 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -307,27 +307,31 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 {
 #ifdef CONFIG_HIGHMEM
 	int node;
-	unsigned long x = 0;
+	unsigned long x;
 	int i;
-	unsigned long dirtyable = highmem_file_pages;
+	unsigned long dirtyable = 0;
 
 	for_each_node_state(node, N_HIGH_MEMORY) {
 		for (i = ZONE_NORMAL + 1; i < MAX_NR_ZONES; i++) {
 			struct zone *z;
+			unsigned long nr_pages;
 
 			if (!is_highmem_idx(i))
 				continue;
 
 			z = &NODE_DATA(node)->node_zones[i];
-			dirtyable += zone_page_state(z, NR_FREE_PAGES);
+			if (!populated_zone(z))
+				continue;
 
+			nr_pages = zone_page_state(z, NR_FREE_PAGES);
 			/* watch for underflows */
-			dirtyable -= min(dirtyable, high_wmark_pages(z));
-
-			x += dirtyable;
+			nr_pages -= min(nr_pages, high_wmark_pages(z));
+			dirtyable += nr_pages;
 		}
 	}
 
+	x = dirtyable + highmem_file_pages;
+
 	/*
 	 * Unreclaimable memory (kernel memory or anonymous memory
 	 * without swap) can bring down the dirtyable pages below
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
