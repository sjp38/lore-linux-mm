Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8216B0038
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 20:45:34 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id rl12so2866399iec.0
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:45:33 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id hf10si3435330icc.208.2014.04.30.17.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 17:45:33 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so2933216iec.35
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:45:33 -0700 (PDT)
Date: Wed, 30 Apr 2014 17:45:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, thp: do not perform sync compaction on pagefault
Message-ID: <alpine.DEB.2.02.1404301744580.8415@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Synchronous memory compaction can be very expensive: it can iterate an enormous 
amount of memory without aborting and it can wait on page locks and writeback to 
complete if a pageblock cannot be defragmented.

Unfortunately, it's too expensive for pagefault for transparent hugepages and 
it's much better to simply fallback to pages.  On 128GB machines, we find that 
synchronous memory compaction can take O(seconds) for a single thp fault.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2656,7 +2656,7 @@ rebalance:
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
-	} else {
+	} else if (!(gfp_mask & __GFP_NO_KSWAPD)) {
 		/*
 		 * High-order allocations do not necessarily loop after
 		 * direct reclaim and reclaim/compaction depends on compaction

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
