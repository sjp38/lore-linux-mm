Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AF39F60044A
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 07:05:17 -0500 (EST)
Date: Sun, 3 Jan 2010 21:04:35 +0900
From: Kazuhisa Ichikawa <ki@epsilou.com>
Subject: [PATCH] mm/page_alloc: fix the range check for backward merging
Message-ID: <20100103120435.GA3576@epsilou.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Kazuhisa Ichikawa <ki@epsilou.com>

The current check for 'backward merging' within add_active_range()
does not seem correct.  start_pfn must be compared against
early_node_map[i].start_pfn (and NOT against .end_pfn) to find out
whether the new region is backward-mergeable with the existing range.

Signed-off-by: Kazuhisa Ichikawa <ki@epsilou.com>
---
 (This patch applies to linux-2.6.33-rc2)

--- a/mm/page_alloc.c	2009-12-25 06:09:41.000000000 +0900
+++ b/mm/page_alloc.c	2010-01-03 19:20:36.000000000 +0900
@@ -3998,7 +3998,7 @@ void __init add_active_range(unsigned in
 		}
 
 		/* Merge backward if suitable */
-		if (start_pfn < early_node_map[i].end_pfn &&
+		if (start_pfn < early_node_map[i].start_pfn &&
 				end_pfn >= early_node_map[i].start_pfn) {
 			early_node_map[i].start_pfn = start_pfn;
 			return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
