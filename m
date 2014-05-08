Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id AFDE36B00C5
	for <linux-mm@kvack.org>; Thu,  8 May 2014 01:30:08 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so2197169pad.16
        for <linux-mm@kvack.org>; Wed, 07 May 2014 22:30:08 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id wg2si14904481pab.290.2014.05.07.22.30.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 22:30:07 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id kp14so2183198pab.40
        for <linux-mm@kvack.org>; Wed, 07 May 2014 22:30:07 -0700 (PDT)
Date: Wed, 7 May 2014 22:30:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, thp: avoid excessive compaction latency during fault
 fix
In-Reply-To: <alpine.DEB.2.02.1405061922010.18635@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1405072229390.19108@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1405061922010.18635@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

mm-thp-avoid-excessive-compaction-latency-during-fault.patch excludes sync
compaction for all high order allocations other than thp.  What we really
want to do is suppress sync compaction for thp, but only during the page
fault path.

Orders greater than PAGE_ALLOC_COSTLY_ORDER aren't necessarily going to
loop again so this is the only way to exhaust our capabilities before
declaring that we can't allocate.

Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2585,16 +2585,13 @@ rebalance:
 	if (page)
 		goto got_pg;
 
-	if (gfp_mask & __GFP_NO_KSWAPD) {
-		/*
-		 * Khugepaged is allowed to try MIGRATE_SYNC_LIGHT, the latency
-		 * of this allocation isn't critical.  Everything else, however,
-		 * should only be allowed to do MIGRATE_ASYNC to avoid excessive
-		 * stalls during fault.
-		 */
-		if ((current->flags & (PF_KTHREAD | PF_KSWAPD)) == PF_KTHREAD)
-			migration_mode = MIGRATE_SYNC_LIGHT;
-	}
+	/*
+	 * It can become very expensive to allocate transparent hugepages at
+	 * fault, so use asynchronous memory compaction for THP unless it is
+	 * khugepaged trying to collapse.
+	 */
+	if (!(gfp_mask & __GFP_NO_KSWAPD) || (current->flags & PF_KTHREAD))
+		migration_mode = MIGRATE_SYNC_LIGHT;
 
 	/*
 	 * If compaction is deferred for high-order allocations, it is because

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
