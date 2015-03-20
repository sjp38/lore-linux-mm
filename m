Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 910326B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:00:41 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so108541832pad.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 06:00:41 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id a9si9325794pas.76.2015.03.20.06.00.39
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 06:00:40 -0700 (PDT)
Message-ID: <550C19F6.9080408@lge.com>
Date: Fri, 20 Mar 2015 22:00:38 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [PATCH][RFCv2] mm/compaction: reset compaction scanner positions
References: <1426743031-30096-1-git-send-email-gioh.kim@lge.com> <550A8BA9.9040005@suse.cz> <550A8E31.4040304@lge.com> <550A9086.3080508@suse.cz> <550B5CD1.5010306@lge.com>
In-Reply-To: <550B5CD1.5010306@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

I'm attaching the patch for discussion.
According to Vlastimil's advice, I move the reseting before compact_zone(),
and write more description.

Vlastimil, can I have your name at Acked-by or Signed-off-by?
Which one do you prefer?

------------------------- 8< ----------------------

 From 575983c887e6478ca7cbba49a892dbc4cd69986b Mon Sep 17 00:00:00 2001
From: Gioh Kim <gioh.kim@lge.com>
Date: Fri, 20 Mar 2015 21:09:13 +0900
Subject: [PATCH] [RFCv2] mm/compaction: reset compaction scanner positions

When the compaction is activated via /proc/sys/vm/compact_memory
it would better scan the whole zone.
And some platform, for instance ARM, has the start_pfn of a zone as zero.
Therefore the first try to compaction via /proc doesn't work.
It needs to force to reset compaction scanner position at first.

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
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

+               /*
+                * When called via /proc/sys/vm/compact_memory
+                * this makes sure we compact the whole zone regardless of
+                * cached scanner positions.
+                */
+               if (cc->order == -1)
+                       __reset_isolation_suitable(zone);
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
