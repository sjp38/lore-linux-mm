Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 143776B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 07:01:39 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id w10so3933232pde.24
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 04:01:38 -0800 (PST)
Received: from mail-pb0-x22b.google.com (mail-pb0-x22b.google.com [2607:f8b0:400e:c01::22b])
        by mx.google.com with ESMTPS id bo2si8100664pbc.201.2014.03.07.04.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Mar 2014 04:01:35 -0800 (PST)
Received: by mail-pb0-f43.google.com with SMTP id um1so4066425pbc.30
        for <linux-mm@kvack.org>; Fri, 07 Mar 2014 04:01:35 -0800 (PST)
Date: Fri, 7 Mar 2014 04:01:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, compaction: determine isolation mode only once
Message-ID: <alpine.DEB.2.02.1403070358120.13046@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The conditions that control the isolation mode in 
isolate_migratepages_range() do not change during the iteration, so 
extract them out and only define the value once.

This actually does have an effect, gcc doesn't optimize it itself because 
of cc->sync.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -454,12 +454,13 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	unsigned long last_pageblock_nr = 0, pageblock_nr;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
 	struct list_head *migratelist = &cc->migratepages;
-	isolate_mode_t mode = 0;
 	struct lruvec *lruvec;
 	unsigned long flags;
 	bool locked = false;
 	struct page *page = NULL, *valid_page = NULL;
 	bool skipped_async_unsuitable = false;
+	const isolate_mode_t mode = (!cc->sync ? ISOLATE_ASYNC_MIGRATE : 0) |
+				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -592,12 +593,6 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			continue;
 		}
 
-		if (!cc->sync)
-			mode |= ISOLATE_ASYNC_MIGRATE;
-
-		if (unevictable)
-			mode |= ISOLATE_UNEVICTABLE;
-
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 
 		/* Try isolate the page */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
