Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1506B003A
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:47 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so1682320eek.6
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c48si23130614eeb.7.2014.04.18.07.50.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:46 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/16] mm: page_alloc: Do not treat a zone that cannot be used for dirty pages as "full"
Date: Fri, 18 Apr 2014 15:50:31 +0100
Message-Id: <1397832643-14275-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

If a zone cannot be used for a dirty page then it gets marked "full"
which is cached in the zlc and later potentially skipped by allocation
requests that have nothing to do with dirty zones.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d8c9c4a..ad702e9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1962,7 +1962,7 @@ zonelist_scan:
 		 */
 		if ((alloc_flags & ALLOC_WMARK_LOW) &&
 		    (gfp_mask & __GFP_WRITE) && !zone_dirty_ok(zone))
-			goto this_zone_full;
+			continue;
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_ok(zone, order, mark,
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
