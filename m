Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 414C96B025E
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 08:58:45 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/4] mm: bootmem: try harder to free pages in bulk
Date: Tue, 13 Dec 2011 14:58:31 +0100
Message-Id: <1323784711-1937-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1323784711-1937-1-git-send-email-hannes@cmpxchg.org>
References: <1323784711-1937-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The loop that frees pages to the page allocator while bootstrapping
tries to free higher-order blocks only when the starting address is
aligned to that block size.  Otherwise it will free all pages on that
node one-by-one.

Change it to free individual pages up to the first aligned block and
then try higher-order frees from there.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/bootmem.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 1aea171..668e94d 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -171,7 +171,6 @@ void __init free_bootmem_late(unsigned long addr, unsigned long size)
 
 static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 {
-	int aligned;
 	struct page *page;
 	unsigned long start, end, pages, count = 0;
 
@@ -181,14 +180,8 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 	start = bdata->node_min_pfn;
 	end = bdata->node_low_pfn;
 
-	/*
-	 * If the start is aligned to the machines wordsize, we might
-	 * be able to free pages in bulks of that order.
-	 */
-	aligned = !(start & (BITS_PER_LONG - 1));
-
-	bdebug("nid=%td start=%lx end=%lx aligned=%d\n",
-		bdata - bootmem_node_data, start, end, aligned);
+	bdebug("nid=%td start=%lx end=%lx\n",
+		bdata - bootmem_node_data, start, end);
 
 	while (start < end) {
 		unsigned long *map, idx, vec;
@@ -196,12 +189,17 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 		map = bdata->node_bootmem_map;
 		idx = start - bdata->node_min_pfn;
 		vec = ~map[idx / BITS_PER_LONG];
-
-		if (aligned && vec == ~0UL) {
+		/*
+		 * If we have a properly aligned and fully unreserved
+		 * BITS_PER_LONG block of pages in front of us, free
+		 * it in one go.
+		 */
+		if (IS_ALIGNED(start, BITS_PER_LONG) && vec == ~0UL) {
 			int order = ilog2(BITS_PER_LONG);
 
 			__free_pages_bootmem(pfn_to_page(start), order);
 			count += BITS_PER_LONG;
+			start += BITS_PER_LONG;
 		} else {
 			unsigned long off = 0;
 
@@ -214,8 +212,8 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 				vec >>= 1;
 				off++;
 			}
+			start = ALIGN(start + 1, BITS_PER_LONG);
 		}
-		start += BITS_PER_LONG;
 	}
 
 	page = virt_to_page(bdata->node_bootmem_map);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
