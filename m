Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DECAA6B006C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:34:34 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so52020889pad.7
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:34:34 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id hq3si1177630pac.11.2015.01.30.04.34.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 04:34:34 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so52017471pad.8
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 04:34:34 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 1/4] mm/compaction: fix wrong order check in compact_finished()
Date: Fri, 30 Jan 2015 21:34:09 +0900
Message-Id: <1422621252-29859-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1422621252-29859-1-git-send-email-iamjoonsoo.kim@lge.com>
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
compaction success rate.

Compaction success rate (Compaction success * 100 / Compaction stalls, %)
18.47 : 28.94

Cc: <stable@vger.kernel.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index b68736c..4954e19 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1173,7 +1173,7 @@ static int __compact_finished(struct zone *zone, struct compact_control *cc,
 			return COMPACT_PARTIAL;
 
 		/* Job done if allocation would set block type */
-		if (cc->order >= pageblock_order && area->nr_free)
+		if (order >= pageblock_order && area->nr_free)
 			return COMPACT_PARTIAL;
 	}
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
