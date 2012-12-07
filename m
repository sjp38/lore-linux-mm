Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 086466B008A
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:11 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/49] mm: compaction: Move migration fail/success stats to migrate.c
Date: Fri,  7 Dec 2012 10:23:11 +0000
Message-Id: <1354875832-9700-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The compact_pages_moved and compact_pagemigrate_failed events are
convenient for determining if compaction is active and to what
degree migration is succeeding but it's at the wrong level. Other
users of migration may also want to know if migration is working
properly and this will be particularly true for any automated
NUMA migration. This patch moves the counters down to migration
with the new events called pgmigrate_success and pgmigrate_fail.
The compact_blocks_moved counter is removed because while it was
useful for debugging initially, it's worthless now as no meaningful
conclusions can be drawn from its value.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/vm_event_item.h |    4 +++-
 mm/compaction.c               |    4 ----
 mm/migrate.c                  |    6 ++++++
 mm/vmstat.c                   |    7 ++++---
 4 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 3d31145..8aa7cb9 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -38,8 +38,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		KSWAPD_SKIP_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+#ifdef CONFIG_MIGRATION
+		PGMIGRATE_SUCCESS, PGMIGRATE_FAIL,
+#endif
 #ifdef CONFIG_COMPACTION
-		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
diff --git a/mm/compaction.c b/mm/compaction.c
index 9eef558..00ad883 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -994,10 +994,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
-		count_vm_event(COMPACTBLOCKS);
-		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
-		if (nr_remaining)
-			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
 		trace_mm_compaction_migratepages(nr_migrate - nr_remaining,
 						nr_remaining);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 77ed2d7..04687f6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -962,6 +962,7 @@ int migrate_pages(struct list_head *from,
 {
 	int retry = 1;
 	int nr_failed = 0;
+	int nr_succeeded = 0;
 	int pass = 0;
 	struct page *page;
 	struct page *page2;
@@ -988,6 +989,7 @@ int migrate_pages(struct list_head *from,
 				retry++;
 				break;
 			case 0:
+				nr_succeeded++;
 				break;
 			default:
 				/* Permanent failure */
@@ -998,6 +1000,10 @@ int migrate_pages(struct list_head *from,
 	}
 	rc = 0;
 out:
+	if (nr_succeeded)
+		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
+	if (nr_failed)
+		count_vm_events(PGMIGRATE_FAIL, nr_failed);
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c737057..89a7fd6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -774,10 +774,11 @@ const char * const vmstat_text[] = {
 
 	"pgrotated",
 
+#ifdef CONFIG_MIGRATION
+	"pgmigrate_success",
+	"pgmigrate_fail",
+#endif
 #ifdef CONFIG_COMPACTION
-	"compact_blocks_moved",
-	"compact_pages_moved",
-	"compact_pagemigrate_failed",
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
