Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 910786B0071
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 21:35:51 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so12745547pdj.12
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 18:35:51 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id fw5si1429146pbb.88.2014.11.03.18.35.48
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 18:35:50 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 for v3.18] mm/compaction: skip the range until proper target pageblock is met
Date: Tue,  4 Nov 2014 11:37:29 +0900
Message-Id: <1415068649-18040-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

commit 7d49d8868336 ("mm, compaction: reduce zone checking frequency in
the migration scanner") makes side-effect that change iteration
range calculation. Before change, block_end_pfn is calculated using
start_pfn, but, now, blindly add pageblock_nr_pages to previous value.

This cause the problem that isolation_start_pfn is larger than
block_end_pfn when we isolate the page with more than pageblock order.
In this case, isolation would be failed due to invalid range parameter.

To prevent this, this patch recalculate the range to find valid target
pageblock. Without this patch, CMA with more than pageblock order always
fail, but, with this patch, it will succeed.

Changes from v1:
recalculate the range rather than just skipping to find valid one.
add code comment.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index ec74cf0..4f0151c 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -479,6 +479,16 @@ isolate_freepages_range(struct compact_control *cc,
 
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
+		/*
+		 * pfn could pass the block_end_pfn if isolated freepage
+		 * is more than pageblock order. In this case, we adjust
+		 * scanning range to right one.
+		 */
+		if (pfn >= block_end_pfn) {
+			block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
+			block_end_pfn = min(block_end_pfn, end_pfn);
+		}
+
 		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
 			break;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
