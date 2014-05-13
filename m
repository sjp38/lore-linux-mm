Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id AD3016B0037
	for <linux-mm@kvack.org>; Tue, 13 May 2014 05:45:57 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so205967eek.17
        for <linux-mm@kvack.org>; Tue, 13 May 2014 02:45:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 44si12681082eef.70.2014.05.13.02.45.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 02:45:56 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/19] mm: page_alloc: Do not treat a zone that cannot be used for dirty pages as "full"
Date: Tue, 13 May 2014 10:45:33 +0100
Message-Id: <1399974350-11089-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1399974350-11089-1-git-send-email-mgorman@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

If a zone cannot be used for a dirty page then it gets marked "full"
which is cached in the zlc and later potentially skipped by allocation
requests that have nothing to do with dirty zones.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f8b80c3..5c559e3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1976,7 +1976,7 @@ zonelist_scan:
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
