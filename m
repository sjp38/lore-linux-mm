Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1F22F6B0038
	for <linux-mm@kvack.org>; Tue,  6 May 2014 22:22:53 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so407844pab.3
        for <linux-mm@kvack.org>; Tue, 06 May 2014 19:22:52 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id nl9si1019615pbc.180.2014.05.06.19.22.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 19:22:52 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id z10so354826pdj.28
        for <linux-mm@kvack.org>; Tue, 06 May 2014 19:22:51 -0700 (PDT)
Date: Tue, 6 May 2014 19:22:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v3 5/6] mm, thp: avoid excessive compaction latency during
 fault
In-Reply-To: <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1405061922010.18635@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Synchronous memory compaction can be very expensive: it can iterate an enormous 
amount of memory without aborting, constantly rescheduling, waiting on page
locks and lru_lock, etc, if a pageblock cannot be defragmented.

Unfortunately, it's too expensive for transparent hugepage page faults and 
it's much better to simply fallback to pages.  On 128GB machines, we find that 
synchronous memory compaction can take O(seconds) for a single thp fault.

Now that async compaction remembers where it left off without strictly relying
on sync compaction, this makes thp allocations best-effort without causing
egregious latency during fault.  We still need to retry async compaction after
reclaim, but this won't stall for seconds.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2584,7 +2584,17 @@ rebalance:
 					&did_some_progress);
 	if (page)
 		goto got_pg;
-	migration_mode = MIGRATE_SYNC_LIGHT;
+
+	if (gfp_mask & __GFP_NO_KSWAPD) {
+		/*
+		 * Khugepaged is allowed to try MIGRATE_SYNC_LIGHT, the latency
+		 * of this allocation isn't critical.  Everything else, however,
+		 * should only be allowed to do MIGRATE_ASYNC to avoid excessive
+		 * stalls during fault.
+		 */
+		if ((current->flags & (PF_KTHREAD | PF_KSWAPD)) == PF_KTHREAD)
+			migration_mode = MIGRATE_SYNC_LIGHT;
+	}
 
 	/*
 	 * If compaction is deferred for high-order allocations, it is because

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
