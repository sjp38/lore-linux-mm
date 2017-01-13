Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C42E6B0253
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:15:06 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j18so54311010ioe.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:06 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id k1si11825293plb.309.2017.01.12.23.15.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 23:15:05 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id y143so7116685pfb.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:15:05 -0800 (PST)
From: js1304@gmail.com
Subject: [RFC PATCH 1/5] mm/vmstat: retrieve suitable free pageblock information just once
Date: Fri, 13 Jan 2017 16:14:29 +0900
Message-Id: <1484291673-2239-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1484291673-2239-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

It's inefficient to retrieve buddy information for fragmentation index
calculation on every order. By using some stack memory, we could retrieve
it once and reuse it to compute all the required values. MAX_ORDER is
usually small enough so there is no big risk about stack overflow.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/vmstat.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7c28df3..e1ca5eb 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -821,7 +821,7 @@ unsigned long node_page_state(struct pglist_data *pgdat,
 struct contig_page_info {
 	unsigned long free_pages;
 	unsigned long free_blocks_total;
-	unsigned long free_blocks_suitable;
+	unsigned long free_blocks_order[MAX_ORDER];
 };
 
 /*
@@ -833,16 +833,14 @@ struct contig_page_info {
  * figured out from userspace
  */
 static void fill_contig_page_info(struct zone *zone,
-				unsigned int suitable_order,
 				struct contig_page_info *info)
 {
 	unsigned int order;
 
 	info->free_pages = 0;
 	info->free_blocks_total = 0;
-	info->free_blocks_suitable = 0;
 
-	for (order = 0; order < MAX_ORDER; order++) {
+	for (order = MAX_ORDER - 1; order >= 0 && order < MAX_ORDER; order--) {
 		unsigned long blocks;
 
 		/* Count number of free blocks */
@@ -851,11 +849,12 @@ static void fill_contig_page_info(struct zone *zone,
 
 		/* Count free base pages */
 		info->free_pages += blocks << order;
+		info->free_blocks_order[order] = blocks;
+		if (order == MAX_ORDER - 1)
+			continue;
 
-		/* Count the suitable free blocks */
-		if (order >= suitable_order)
-			info->free_blocks_suitable += blocks <<
-						(order - suitable_order);
+		info->free_blocks_order[order] +=
+			(info->free_blocks_order[order + 1] << 1);
 	}
 }
 
@@ -874,7 +873,7 @@ static int __fragmentation_index(unsigned int order, struct contig_page_info *in
 		return 0;
 
 	/* Fragmentation index only makes sense when a request would fail */
-	if (info->free_blocks_suitable)
+	if (info->free_blocks_order[order])
 		return -1000;
 
 	/*
@@ -891,7 +890,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 {
 	struct contig_page_info info;
 
-	fill_contig_page_info(zone, order, &info);
+	fill_contig_page_info(zone, &info);
 	return __fragmentation_index(order, &info);
 }
 #endif
@@ -1811,7 +1810,7 @@ static int unusable_free_index(unsigned int order,
 	 * 0 => no fragmentation
 	 * 1 => high fragmentation
 	 */
-	return div_u64((info->free_pages - (info->free_blocks_suitable << order)) * 1000ULL, info->free_pages);
+	return div_u64((info->free_pages - (info->free_blocks_order[order] << order)) * 1000ULL, info->free_pages);
 
 }
 
@@ -1825,8 +1824,8 @@ static void unusable_show_print(struct seq_file *m,
 	seq_printf(m, "Node %d, zone %8s ",
 				pgdat->node_id,
 				zone->name);
+	fill_contig_page_info(zone, &info);
 	for (order = 0; order < MAX_ORDER; ++order) {
-		fill_contig_page_info(zone, order, &info);
 		index = unusable_free_index(order, &info);
 		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
 	}
@@ -1887,8 +1886,8 @@ static void extfrag_show_print(struct seq_file *m,
 	seq_printf(m, "Node %d, zone %8s ",
 				pgdat->node_id,
 				zone->name);
+	fill_contig_page_info(zone, &info);
 	for (order = 0; order < MAX_ORDER; ++order) {
-		fill_contig_page_info(zone, order, &info);
 		index = __fragmentation_index(order, &info);
 		seq_printf(m, "%d.%03d ", index / 1000, index % 1000);
 	}
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
