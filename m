Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4346B0261
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:00:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so31932156wmr.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 03:00:13 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id k3si27015369wma.135.2016.07.13.03.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 03:00:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id C1E341C204C
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:00:06 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 3/4] mm, page_alloc: fix dirtyable highmem calculation
Date: Wed, 13 Jul 2016 11:00:03 +0100
Message-Id: <1468404004-5085-4-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

From: Minchan Kim <minchan@kernel.org>

Note from Mel: This may optionally be considered a fix to the mmotm patch
	mm-page_alloc-consider-dirtyable-memory-in-terms-of-nodes.patch
	but if so, please preserve credit for Minchan.

When I tested vmscale in mmtest in 32bit, I found the benchmark was slow
down 0.5 times.

                base        node
                   1    global-1
User           12.98       16.04
System        147.61      166.42
Elapsed        26.48       38.08

With vmstat, I found IO wait avg is much increased compared to base.

The reason was highmem_dirtyable_memory accumulates free pages and
highmem_file_pages from HIGHMEM to MOVABLE zones which was wrong. With
that, dirth_thresh in throtlle_vm_write is always 0 so that it calls
congestion_wait frequently if writeback starts.

With this patch, it is much recovered.

                base        node          fi
                   1    global-1         fix
User           12.98       16.04       13.78
System        147.61      166.42      143.92
Elapsed        26.48       38.08       29.64

Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page-writeback.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 0bca2376bd42..7b41d1290783 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -307,27 +307,31 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 {
 #ifdef CONFIG_HIGHMEM
 	int node;
-	unsigned long x = 0;
+	unsigned long x;
 	int i;
-	unsigned long dirtyable = atomic_read(&highmem_file_pages);
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
 
+	x = dirtyable + atomic_read(&highmem_file_pages);
+
 	/*
 	 * Unreclaimable memory (kernel memory or anonymous memory
 	 * without swap) can bring down the dirtyable pages below
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
