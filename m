Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D6D0D6B0038
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 07:58:11 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so134882746pdn.0
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 04:58:11 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id zb2si2230200pbb.57.2015.03.21.04.58.10
        for <linux-mm@kvack.org>;
        Sat, 21 Mar 2015 04:58:11 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [PATCH] mm/compaction: reset compaction scanner positions
Date: Sat, 21 Mar 2015 20:58:26 +0900
Message-Id: <1426939106-30347-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com, Gioh Kim <gioh.kim@lge.com>Gioh Kim <gioh.kim@lge.c>

When the compaction is activated via /proc/sys/vm/compact_memory
it would better scan the whole zone.
And some platform, for instance ARM, has the start_pfn of a zone is zero.
Therefore the first try to compaction via /proc doesn't work.
It needs to force to reset compaction scanner position at first.

Signed-off-by: Gioh Kim <gioh.kim@lge.c>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
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
