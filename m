Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id C146B6B0031
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 05:26:35 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id q59so326172wes.27
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 02:26:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kd7si30423880wjc.149.2014.06.09.02.26.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 02:26:34 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 04/10] mm, compaction: skip rechecks when lock was already held
Date: Mon,  9 Jun 2014 11:26:16 +0200
Message-Id: <1402305982-6928-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

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
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
V2: remove goto skip_recheck

 mm/compaction.c | 53 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 31 insertions(+), 22 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index e1a4283..83f72bd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -334,22 +334,30 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
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
@@ -658,19 +666,20 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
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
