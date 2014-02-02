Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF166B0031
	for <linux-mm@kvack.org>; Sun,  2 Feb 2014 00:46:30 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id jt11so5943444pbb.29
        for <linux-mm@kvack.org>; Sat, 01 Feb 2014 21:46:29 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id eb3si16092974pbc.236.2014.02.01.21.46.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 01 Feb 2014 21:46:29 -0800 (PST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so5941986pad.14
        for <linux-mm@kvack.org>; Sat, 01 Feb 2014 21:46:28 -0800 (PST)
Date: Sat, 1 Feb 2014 21:46:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: avoid isolating pinned pages
Message-ID: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Page migration will fail for memory that is pinned in memory with, for
example, get_user_pages().  In this case, it is unnecessary to take
zone->lru_lock or isolating the page and passing it to page migration
which will ultimately fail.

This is a racy check, the page can still change from under us, but in
that case we'll just fail later when attempting to move the page.

This avoids very expensive memory compaction when faulting transparent
hugepages after pinning a lot of memory with a Mellanox driver.

On a 128GB machine and pinning ~120GB of memory, before this patch we
see the enormous disparity in the number of page migration failures
because of the pinning (from /proc/vmstat):

compact_blocks_moved 7609
compact_pages_moved 3431
compact_pagemigrate_failed 133219
compact_stall 13

After the patch, it is much more efficient:

compact_blocks_moved 7998
compact_pages_moved 6403
compact_pagemigrate_failed 3
compact_stall 15

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -578,6 +578,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			continue;
 		}
 
+		/*
+		 * Migration will fail if an anonymous page is pinned in memory,
+		 * so avoid taking zone->lru_lock and isolating it unnecessarily
+		 * in an admittedly racy check.
+		 */
+		if (!page_mapping(page) && page_count(page))
+			continue;
+
 		/* Check if it is ok to still hold the lock */
 		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
 								locked, cc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
