Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id C9A176B0098
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 09:49:03 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id u57so954099wes.24
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:49:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fo5si20626814wib.50.2014.07.16.06.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 06:48:57 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V4 09/15] mm, compaction: skip rechecks when lock was already held
Date: Wed, 16 Jul 2014 15:48:17 +0200
Message-Id: <1405518503-27687-10-git-send-email-vbabka@suse.cz>
In-Reply-To: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Compaction scanners try to lock zone locks as late as possible by checking
many page or pageblock properties opportunistically without lock and skipping
them if not unsuitable. For pages that pass the initial checks, some properties
have to be checked again safely under lock. However, if the lock was already
held from a previous iteration in the initial checks, the rechecks are
unnecessary.

This patch therefore skips the rechecks when the lock was already held. This is
now possible to do, since we don't (potentially) drop and reacquire the lock
between the initial checks and the safe rechecks anymore.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 53 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 31 insertions(+), 22 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index b213e0ba..2b42397 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -367,22 +367,30 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 			goto isolate_fail;
 
 		/*
-		 * The zone lock must be held to isolate freepages.
-		 * Unfortunately this is a very coarse lock and can be
-		 * heavily contended if there are parallel allocations
-		 * or parallel compactions. For async compaction do not
-		 * spin on the lock and we acquire the lock as late as
-		 * possible.
+		 * If we already hold the lock, we can skip some rechecking.
+		 * Note that if we hold the lock now, checked_pageblock was
+		 * already set in some previous iteration (or strict is true),
+		 * so it is correct to skip the suitable migration target
+		 * recheck as well.
 		 */
-		if (!locked)
+		if (!locked) {
+			/*
+			 * The zone lock must be held to isolate freepages.
+			 * Unfortunately this is a very coarse lock and can be
+			 * heavily contended if there are parallel allocations
+			 * or parallel compactions. For async compaction do not
+			 * spin on the lock and we acquire the lock as late as
+			 * possible.
+			 */
 			locked = compact_trylock_irqsave(&cc->zone->lock,
 								&flags, cc);
-		if (!locked)
-			break;
+			if (!locked)
+				break;
 
-		/* Recheck this is a buddy page under lock */
-		if (!PageBuddy(page))
-			goto isolate_fail;
+			/* Recheck this is a buddy page under lock */
+			if (!PageBuddy(page))
+				goto isolate_fail;
+		}
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
@@ -644,19 +652,20 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		    page_count(page) > page_mapcount(page))
 			continue;
 
-		/* If the lock is not held, try to take it */
-		if (!locked)
+		/* If we already hold the lock, we can skip some rechecking */
+		if (!locked) {
 			locked = compact_trylock_irqsave(&zone->lru_lock,
 								&flags, cc);
-		if (!locked)
-			break;
+			if (!locked)
+				break;
 
-		/* Recheck PageLRU and PageTransHuge under lock */
-		if (!PageLRU(page))
-			continue;
-		if (PageTransHuge(page)) {
-			low_pfn += (1 << compound_order(page)) - 1;
-			continue;
+			/* Recheck PageLRU and PageTransHuge under lock */
+			if (!PageLRU(page))
+				continue;
+			if (PageTransHuge(page)) {
+				low_pfn += (1 << compound_order(page)) - 1;
+				continue;
+			}
 		}
 
 		lruvec = mem_cgroup_page_lruvec(page, zone);
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
