Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9418D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:17:29 -0500 (EST)
Received: by pvc30 with SMTP id 30so155609pvc.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 08:17:27 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 3/3] compaction: Check migrate_pages's return value instead of list_empty
Date: Fri, 21 Jan 2011 01:17:07 +0900
Message-Id: <8d3d2470533ab99564cdcec88bfb7fcc96b383d3.1295539829.git.minchan.kim@gmail.com>
In-Reply-To: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
In-Reply-To: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
References: <f60d811fd1abcb68d40ac19af35881d700a97cd2.1295539829.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Many migrate_page's caller check return value instead of list_empy by
cf608ac19c95804dc2.
This patch makes compaction's migrate_pages consistent with others.
This patch should not change old behavior.

NOTE : This patch depends on [1/3].

Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6d592a0..cd0c7fc 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -497,12 +497,13 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
 		unsigned long nr_migrate, nr_remaining;
+		int err;
 
 		if (!isolate_migratepages(zone, cc))
 			continue;
 
 		nr_migrate = cc->nr_migratepages;
-		migrate_pages(&cc->migratepages, compaction_alloc,
+		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				(unsigned long)cc, false,
 				cc->sync);
 		update_nr_listpages(cc);
@@ -516,7 +517,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 						nr_remaining);
 
 		/* Release LRU pages not migrated */
-		if (!list_empty(&cc->migratepages)) {
+		if (err) {
 			putback_lru_pages(&cc->migratepages);
 			cc->nr_migratepages = 0;
 		}
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
