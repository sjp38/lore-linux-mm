Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B2B29280028
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:22:28 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so6775794pdb.13
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 00:22:28 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id v1si8582616pdh.125.2014.10.31.00.22.26
        for <linux-mm@kvack.org>;
        Fri, 31 Oct 2014 00:22:27 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH for v3.18] mm/compaction: skip the range until proper target pageblock is met
Date: Fri, 31 Oct 2014 16:23:55 +0900
Message-Id: <1414740235-3975-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

commit 7d49d8868336 ("mm, compaction: reduce zone checking frequency in
the migration scanner") makes side-effect that change iteration
range calculation. Before change, block_end_pfn is calculated using
start_pfn, but, now, blindly add pageblock_nr_pages to previous value.

This cause the problem that isolation_start_pfn is larger than
block_end_pfn when we isolation the page with more than pageblock order.
In this case, isolation would be failed due to invalid range parameter.

To prevent this, this patch implement skipping the range until proper
target pageblock is met. Without this patch, CMA with more than pageblock
order always fail, but, with this patch, it will succeed.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index ec74cf0..212682a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -472,18 +472,20 @@ isolate_freepages_range(struct compact_control *cc,
 	pfn = start_pfn;
 	block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 
-	for (; pfn < end_pfn; pfn += isolated,
-				block_end_pfn += pageblock_nr_pages) {
+	for (; pfn < end_pfn; block_end_pfn += pageblock_nr_pages) {
 		/* Protect pfn from changing by isolate_freepages_block */
 		unsigned long isolate_start_pfn = pfn;
 
 		block_end_pfn = min(block_end_pfn, end_pfn);
+		if (pfn >= block_end_pfn)
+			continue;
 
 		if (!pageblock_pfn_to_page(pfn, block_end_pfn, cc->zone))
 			break;
 
 		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
 						block_end_pfn, &freelist, true);
+		pfn += isolated;
 
 		/*
 		 * In strict mode, isolate_freepages_block() returns 0 if
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
