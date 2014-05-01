Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id BD8AB6B0038
	for <linux-mm@kvack.org>; Thu,  1 May 2014 17:35:51 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fb1so4297364pad.10
        for <linux-mm@kvack.org>; Thu, 01 May 2014 14:35:51 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id yd10si21961655pab.330.2014.05.01.14.35.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 01 May 2014 14:35:50 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id ey11so4271189pad.17
        for <linux-mm@kvack.org>; Thu, 01 May 2014 14:35:50 -0700 (PDT)
Date: Thu, 1 May 2014 14:35:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2 4/4] mm, thp: do not perform sync compaction on
 pagefault
In-Reply-To: <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1405011435210.23898@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Synchronous memory compaction can be very expensive: it can iterate an enormous 
amount of memory without aborting, constantly rescheduling, waiting on page
locks and lru_lock, etc, if a pageblock cannot be defragmented.

Unfortunately, it's too expensive for pagefault for transparent hugepages and 
it's much better to simply fallback to pages.  On 128GB machines, we find that 
synchronous memory compaction can take O(seconds) for a single thp fault.

Now that async compaction remembers where it left off without strictly relying
on sync compaction, this makes thp allocations best-effort without causing
egregious latency during pagefault.

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
