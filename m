Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4451E6B0012
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 03:57:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id k4-v6so7164717pls.15
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 00:57:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x3sor2014177pge.167.2018.03.23.00.57.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Mar 2018 00:57:42 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH v1] mm: help the ALLOC_HARDER allocation pass the watermarki when CMA on
Date: Fri, 23 Mar 2018 15:57:32 +0800
Message-Id: <1521791852-7048-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, vel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org

For the type of 'ALLOC_HARDER' page allocation, there is an express
highway for the whole process which lead the allocation reach __rmqueue_xxx
easier than other type.
However, when CMA is enabled, the free_page within zone_watermark_ok() will
be deducted for number the pages in CMA type, which may cause the watermark
check fail, but there are possible enough HighAtomic or Unmovable and
Reclaimable pages in the zone. So add 'alloc_harder' here to
count CMA pages in to clean the obstacles on the way to the final.

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
---
 mm/page_alloc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 635d7dd..cc18620 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3045,8 +3045,11 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 
 
 #ifdef CONFIG_CMA
-	/* If allocation can't use CMA areas don't use free CMA pages */
-	if (!(alloc_flags & ALLOC_CMA))
+	/*
+	 * If allocation can't use CMA areas and no alloc_harder set for none
+	 * order0 allocation, don't use free CMA pages.
+	 */
+	if (!(alloc_flags & ALLOC_CMA) && (!alloc_harder || !order))
 		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
 #endif
 
-- 
1.9.1
