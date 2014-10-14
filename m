Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 60FE06B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 22:26:06 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so6812749pad.22
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 19:26:05 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fn1si11567702pbb.223.2014.10.13.19.26.03
        for <linux-mm@kvack.org>;
        Mon, 13 Oct 2014 19:26:04 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH] mm/compaction: avoid premature range skip in isolate_migratepages_range
Date: Tue, 14 Oct 2014 11:26:28 +0900
Message-Id: <1413253588-26457-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

commit edc2ca612496 ("mm, compaction: move pageblock checks up from
isolate_migratepages_range()") commonizes isolate_migratepages variants
and make them use isolate_migratepages_block().
isolate_migratepages_block() could stop the execution when enough pages
are isolated, but, there is no code in isolate_migratepages_range()
to handle this case. In the result, even if isolate_migratepages_block()
returns prematurely without checking all pages in the range,
isolate_migratepages_block() is called repeately on the following
pageblock and some pages in the previous range are skipped to check.
Then, CMA is failed frequently due to this fact.

To fix this problem, this patch let isolate_migratepages_range() know
the situation that enough pages are isolated and stop the isolation
in that case.

Note that isolate_migratepages() has no such problem, because, it always
stops the isolation after just one call of isolate_migratepages_block().

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index edba18a..ec74cf0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -784,6 +784,9 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
 			cc->nr_migratepages = 0;
 			break;
 		}
+
+		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
+			break;
 	}
 	acct_isolated(cc->zone, cc);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
