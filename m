Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 188336B006C
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 02:12:43 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so4696859pac.39
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 23:12:42 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ji4si44503299pbb.42.2014.12.07.23.12.39
        for <linux-mm@kvack.org>;
        Sun, 07 Dec 2014 23:12:41 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/4] mm/compaction: fix wrong order check in compact_finished()
Date: Mon,  8 Dec 2014 16:16:17 +0900
Message-Id: <1418022980-4584-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

What we want to check here is whether there is highorder freepage
in buddy list of other migratetype in order to steal it without
fragmentation. But, current code just checks cc->order which means
allocation request order. So, this is wrong.

Without this fix, non-movable synchronous compaction below pageblock order
would not stopped until compaction is complete, because migratetype of most
pageblocks are movable and high order freepage made by compaction is usually
on movable type buddy list.

There is some report related to this bug. See below link.

http://www.spinics.net/lists/linux-mm/msg81666.html

Although the issued system still has load spike comes from compaction,
this makes that system completely stable and responsive according to
his report.

stress-highalloc test in mmtests with non movable order 7 allocation doesn't
show any notable difference in allocation success rate, but, it shows more
compaction success rate and reduced elapsed time.

Compaction success rate (Compaction success * 100 / Compaction stalls, %)
18.47 : 28.94

Elapsed time (sec)
1429 : 1411

Cc: <stable@vger.kernel.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index c9ee464..1a5f465 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1105,7 +1105,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 			return COMPACT_PARTIAL;
 
 		/* Job done if allocation would set block type */
-		if (cc->order >= pageblock_order && area->nr_free)
+		if (order >= pageblock_order && area->nr_free)
 			return COMPACT_PARTIAL;
 	}
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
