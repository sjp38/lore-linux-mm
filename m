Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 08F8B6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 21:35:25 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so204736772pdb.3
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 18:35:24 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ev2si3378953pdb.74.2015.03.23.18.35.20
        for <linux-mm@kvack.org>;
        Mon, 23 Mar 2015 18:35:24 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [PATCHv2] mm/compaction: reset compaction scanner positions
Date: Tue, 24 Mar 2015 10:31:52 +0900
Message-Id: <1427160712-16064-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com, Gioh Kim <gioh.kim@lge.com>

When the compaction is activated via /proc/sys/vm/compact_memory
it would better scan the whole zone.
And some platform, for instance ARM, has the start_pfn of a zone is zero.
Therefore the first try to compaction via /proc doesn't work.
It needs to force to reset compaction scanner position at first.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 8c0d945..ccf48ce 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1587,6 +1587,14 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 		INIT_LIST_HEAD(&cc->freepages);
 		INIT_LIST_HEAD(&cc->migratepages);
 
+		/*
+		 * When called via /proc/sys/vm/compact_memory
+		 * this makes sure we compact the whole zone regardless of
+		 * cached scanner positions.
+		 */
+		if (cc->order == -1)
+			__reset_isolation_suitable(zone);
+
 		if (cc->order == -1 || !compaction_deferred(zone, cc->order))
 			compact_zone(zone, cc);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
