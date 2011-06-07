Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8646B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 11:07:11 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/4] mm: compaction: Ensure that the compaction free scanner does not move to the next zone
Date: Tue,  7 Jun 2011 16:07:02 +0100
Message-Id: <1307459225-4481-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1307459225-4481-1-git-send-email-mgorman@suse.de>
References: <1307459225-4481-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Thomas Sattler <tsattler@gmx.de>, Ury Stankevich <urykhy@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Compaction works with two scanners, a migration and a free
scanner. When the scanners crossover, migration within the zone is
complete. The location of the scanner is recorded on each cycle to
avoid excesive scanning.

When a zone is small and mostly reserved, it's very easy for the
migration scanner to be close to the end of the zone. Then the following
situation can occurs

  o migration scanner isolates some pages near the end of the zone
  o free scanner starts at the end of the zone but finds that the
    migration scanner is already there
  o free scanner gets reinitialised for the next cycle as
    cc->migrate_pfn + pageblock_nr_pages
    moving the free scanner into the next zone
  o migration scanner moves into the next zone

When this happens, NR_ISOLATED accounting goes haywire because some
of the accounting happens against the wrong zone. One zones counter
remains positive while the other goes negative even though the overall
global count is accurate. This was reported on X86-32 with !SMP because
!SMP allows the negative counters to be visible. The fact that it is
difficult to reproduce on X86-64 is probably just a co-incidence as
the bug should theoritically be possible there.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/compaction.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 021a296..5c744ab 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -144,9 +144,20 @@ static void isolate_freepages(struct zone *zone,
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
+	/*
+	 * Initialise the free scanner. The starting point is where we last
+	 * scanned from (or the end of the zone if starting). The low point
+	 * is the end of the pageblock the migration scanner is using.
+	 */
 	pfn = cc->free_pfn;
 	low_pfn = cc->migrate_pfn + pageblock_nr_pages;
-	high_pfn = low_pfn;
+
+	/*
+	 * Take care that if the migration scanner is at the end of the zone
+	 * that the free scanner does not accidentally move to the next zone
+	 * in the next isolation cycle.
+	 */
+	high_pfn = min(low_pfn, pfn);
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
