Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 410DA6B0035
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:54:09 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so11886329pab.12
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:54:08 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id qx4si4648280pbc.105.2014.02.13.22.54.07
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:54:08 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 3/5] mm/compaction: change the timing to check to drop the spinlock
Date: Fri, 14 Feb 2014 15:54:01 +0900
Message-Id: <1392360843-22261-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392360843-22261-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It is odd to drop the spinlock when we scan (SWAP_CLUSTER_MAX - 1) th pfn
page. This may results in below situation while isolating migratepage.

1. try isolate 0x0 ~ 0x200 pfn pages.
2. When low_pfn is 0x1ff, ((low_pfn+1) % SWAP_CLUSTER_MAX) == 0, so drop
the spinlock.
3. Then, to complete isolating, retry to aquire the lock.

I think that it is better to use SWAP_CLUSTER_MAX th pfn for checking
the criteria about dropping the lock. This has no harm 0x0 pfn, because,
at this time, locked variable would be false.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index 0d821a2..b1ba297 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -481,7 +481,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	cond_resched();
 	for (; low_pfn < end_pfn; low_pfn++) {
 		/* give a chance to irqs before checking need_resched() */
-		if (locked && !((low_pfn+1) % SWAP_CLUSTER_MAX)) {
+		if (locked && !(low_pfn % SWAP_CLUSTER_MAX)) {
 			if (should_release_lock(&zone->lru_lock)) {
 				spin_unlock_irqrestore(&zone->lru_lock, flags);
 				locked = false;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
