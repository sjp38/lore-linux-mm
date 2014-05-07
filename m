Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6BCE46B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 08:09:34 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so675270eek.2
        for <linux-mm@kvack.org>; Wed, 07 May 2014 05:09:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si16155314eeo.244.2014.05.07.05.09.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 05:09:32 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 1/2] mm/compaction: do not count migratepages when unnecessary
Date: Wed,  7 May 2014 14:09:09 +0200
Message-Id: <1399464550-26447-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

During compaction, update_nr_listpages() has been used to count remaining
non-migrated and free pages after a call to migrage_pages(). The freepages
counting has become unneccessary, and it turns out that migratepages counting
is also unnecessary in most cases.

The only situation when it's needed to count cc->migratepages is when
migrate_pages() returns with a negative error code. Otherwise, the non-negative
return value is the number of pages that were not migrated, which is exactly
the count of remaining pages in the cc->migratepages list.

Furthermore, any non-zero count is only interesting for the tracepoint of
mm_compaction_migratepages events, because after that all remaining unmigrated
pages are put back and their count is set to 0.

This patch therefore removes update_nr_listpages() completely, and changes the
tracepoint definition so that the manual counting is done only when the
tracepoint is enabled, and only when migrate_pages() returns a negative error
code.

Furthermore, migrate_pages() and the tracepoints won't be called when there's
nothing to migrate. This potentially avoids some wasted cycles and reduces the
volume of uninteresting mm_compaction_migratepages events where "nr_migrated=0
nr_failed=0". In the stress-highalloc mmtest, this was about 75% of the events.
The mm_compaction_isolate_migratepages event is better for determining that
nothing was isolated for migration, and this one was just duplicating the info.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
 v2: checkpack and other non-functional fixes suggested by Naoya Horiguchi

 include/trace/events/compaction.h | 26 ++++++++++++++++++++++----
 mm/compaction.c                   | 31 +++++++------------------------
 2 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 06f544e..aacaf0f 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -5,7 +5,9 @@
 #define _TRACE_COMPACTION_H
 
 #include <linux/types.h>
+#include <linux/list.h>
 #include <linux/tracepoint.h>
+#include <linux/mm_types.h>
 #include <trace/events/gfpflags.h>
 
 DECLARE_EVENT_CLASS(mm_compaction_isolate_template,
@@ -47,10 +49,11 @@ DEFINE_EVENT(mm_compaction_isolate_template, mm_compaction_isolate_freepages,
 
 TRACE_EVENT(mm_compaction_migratepages,
 
-	TP_PROTO(unsigned long nr_migrated,
-		unsigned long nr_failed),
+	TP_PROTO(unsigned long nr_all,
+		int migrate_rc,
+		struct list_head *migratepages),
 
-	TP_ARGS(nr_migrated, nr_failed),
+	TP_ARGS(nr_all, migrate_rc, migratepages),
 
 	TP_STRUCT__entry(
 		__field(unsigned long, nr_migrated)
@@ -58,7 +61,22 @@ TRACE_EVENT(mm_compaction_migratepages,
 	),
 
 	TP_fast_assign(
-		__entry->nr_migrated = nr_migrated;
+		unsigned long nr_failed = 0;
+		struct page *page;
+
+		/*
+		 * migrate_pages() returns either a non-negative number
+		 * with the number of pages that failed migration, or an
+		 * error code, in which case we need to count the remaining
+		 * pages manually
+		 */
+		if (migrate_rc >= 0)
+			nr_failed = migrate_rc;
+		else
+			list_for_each_entry(page, migratepages, lru)
+				nr_failed++;
+
+		__entry->nr_migrated = nr_all - nr_failed;
 		__entry->nr_failed = nr_failed;
 	),
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 6f4b218..383d562 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -819,22 +819,6 @@ static void compaction_free(struct page *page, unsigned long data)
 	cc->nr_freepages++;
 }
 
-/*
- * We cannot control nr_migratepages fully when migration is running as
- * migrate_pages() has no knowledge of of compact_control.  When migration is
- * complete, we count the number of pages on the list by hand.
- */
-static void update_nr_listpages(struct compact_control *cc)
-{
-	int nr_migratepages = 0;
-	struct page *page;
-
-	list_for_each_entry(page, &cc->migratepages, lru)
-		nr_migratepages++;
-
-	cc->nr_migratepages = nr_migratepages;
-}
-
 /* possible outcome of isolate_migratepages */
 typedef enum {
 	ISOLATE_ABORT,		/* Abort compaction now */
@@ -1029,7 +1013,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 	migrate_prep_local();
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
-		unsigned long nr_migrate, nr_remaining;
 		int err;
 
 		switch (isolate_migratepages(zone, cc)) {
@@ -1044,20 +1027,20 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 			;
 		}
 
-		nr_migrate = cc->nr_migratepages;
+		if (!cc->nr_migratepages)
+			continue;
+
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				compaction_free, (unsigned long)cc, cc->mode,
 				MR_COMPACTION);
-		update_nr_listpages(cc);
-		nr_remaining = cc->nr_migratepages;
 
-		trace_mm_compaction_migratepages(nr_migrate - nr_remaining,
-						nr_remaining);
+		trace_mm_compaction_migratepages(cc->nr_migratepages, err,
+							&cc->migratepages);
 
-		/* Release isolated pages not migrated */
+		/* All pages were either migrated or will be released */
+		cc->nr_migratepages = 0;
 		if (err) {
 			putback_movable_pages(&cc->migratepages);
-			cc->nr_migratepages = 0;
 			/*
 			 * migrate_pages() may return -ENOMEM when scanners meet
 			 * and we want compact_finished() to detect it
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
