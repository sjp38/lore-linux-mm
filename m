Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 9C0F56B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 23:56:37 -0500 (EST)
From: Huang Shijie <b32955@freescale.com>
Subject: [PATCH] mm/compaction : do optimazition when the migration scanner gets no page
Date: Fri, 6 Jan 2012 12:57:41 +0800
Message-ID: <1325825861-3702-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, linux-mm@kvack.org, shijie8@gmail.com, Huang Shijie <b32955@freescale.com>

In the real tests, there are maybe many times the cc->nr_migratepages is zero,
but isolate_migratepages() returns ISOLATE_SUCCESS.
In order to get better performance, we should check the number of the
really isolated pages. And do the optimazition for this case.

Also fix the confused comments(from Mel Gorman).

Tested this patch in MX6Q board.

Signed-off-by: Huang Shijie <b32955@freescale.com>
---
 mm/compaction.c |   28 ++++++++++++++++------------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index bf8e8b2..b40d904 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -246,8 +246,8 @@ static bool too_many_isolated(struct zone *zone)
 /* possible outcome of isolate_migratepages */
 typedef enum {
 	ISOLATE_ABORT,		/* Abort compaction now */
-	ISOLATE_NONE,		/* No pages isolated, continue scanning */
-	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
+	ISOLATE_NONE,		/* No pages scanned, consider next pageblock*/
+	ISOLATE_SUCCESS,	/* Pages scanned and maybe isolated, migrate */
 } isolate_migrate_t;
 
 /*
@@ -540,7 +540,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
 		unsigned long nr_migrate, nr_remaining;
-		int err;
+		int err = 0;
 
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
@@ -552,17 +552,21 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			;
 		}
 
-		nr_migrate = cc->nr_migratepages;
-		err = migrate_pages(&cc->migratepages, compaction_alloc,
-				(unsigned long)cc, false,
-				cc->sync);
-		update_nr_listpages(cc);
-		nr_remaining = cc->nr_migratepages;
+		nr_migrate = nr_remaining = cc->nr_migratepages;
+		if (nr_migrate) {
+			err = migrate_pages(&cc->migratepages, compaction_alloc,
+					(unsigned long)cc, false,
+					cc->sync);
+			update_nr_listpages(cc);
+			nr_remaining = cc->nr_migratepages;
+			count_vm_events(COMPACTPAGES,
+					nr_migrate - nr_remaining);
+			if (nr_remaining)
+				count_vm_events(COMPACTPAGEFAILED,
+						nr_remaining);
+		}
 
 		count_vm_event(COMPACTBLOCKS);
-		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
-		if (nr_remaining)
-			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
 		trace_mm_compaction_migratepages(nr_migrate - nr_remaining,
 						nr_remaining);
 
-- 
1.7.3.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
