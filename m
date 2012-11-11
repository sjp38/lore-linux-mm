Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id F0D306B005D
	for <linux-mm@kvack.org>; Sun, 11 Nov 2012 14:02:02 -0500 (EST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v12 4/7] mm: introduce compaction and migration for ballooned pages
Date: Sun, 11 Nov 2012 17:01:17 -0200
Message-Id: <6602296b38c073a5c6faa13ddbc74ceb1eceb2dd.1352656285.git.aquini@redhat.com>
In-Reply-To: <cover.1352656285.git.aquini@redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
In-Reply-To: <cover.1352656285.git.aquini@redhat.com>
References: <cover.1352656285.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "Michael S. Tsirkin" <mst@redhat.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, aquini@redhat.com

Memory fragmentation introduced by ballooning might reduce significantly
the number of 2MB contiguous memory blocks that can be used within a guest,
thus imposing performance penalties associated with the reduced number of
transparent huge pages that could be used by the guest workload.

This patch introduces the helper functions as well as the necessary changes
to teach compaction and migration bits how to cope with pages which are
part of a guest memory balloon, in order to make them movable by memory
compaction procedures.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/compaction.c | 21 +++++++++++++++++++--
 mm/migrate.c    | 34 ++++++++++++++++++++++++++++++++--
 2 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9eef558..76abd84 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -14,6 +14,7 @@
 #include <linux/backing-dev.h>
 #include <linux/sysctl.h>
 #include <linux/sysfs.h>
+#include <linux/balloon_compaction.h>
 #include "internal.h"
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
@@ -565,9 +566,24 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			goto next_pageblock;
 		}
 
-		/* Check may be lockless but that's ok as we recheck later */
-		if (!PageLRU(page))
+		/*
+		 * Check may be lockless but that's ok as we recheck later.
+		 * It's possible to migrate LRU pages and balloon pages
+		 * Skip any other type of page
+		 */
+		if (!PageLRU(page)) {
+			if (unlikely(balloon_page_movable(page))) {
+				if (locked && balloon_page_isolate(page)) {
+					/* Successfully isolated */
+					cc->finished_update_migrate = true;
+					list_add(&page->lru, migratelist);
+					cc->nr_migratepages++;
+					nr_isolated++;
+					goto check_compact_cluster;
+				}
+			}
 			continue;
+		}
 
 		/*
 		 * PageLRU is set. lru_lock normally excludes isolation
@@ -621,6 +637,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		cc->nr_migratepages++;
 		nr_isolated++;
 
+check_compact_cluster:
 		/* Avoid isolating too much */
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX) {
 			++low_pfn;
diff --git a/mm/migrate.c b/mm/migrate.c
index 6f408c7..a771751 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -35,6 +35,7 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
+#include <linux/balloon_compaction.h>
 
 #include <asm/tlbflush.h>
 
@@ -79,7 +80,10 @@ void putback_lru_pages(struct list_head *l)
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
-		putback_lru_page(page);
+		if (unlikely(balloon_page_movable(page)))
+			balloon_page_putback(page);
+		else
+			putback_lru_page(page);
 	}
 }
 
@@ -778,6 +782,18 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		}
 	}
 
+	if (unlikely(balloon_page_movable(page))) {
+		/*
+		 * A ballooned page does not need any special attention from
+		 * physical to virtual reverse mapping procedures.
+		 * Skip any attempt to unmap PTEs or to remap swap cache,
+		 * in order to avoid burning cycles at rmap level, and perform
+		 * the page migration right away (proteced by page lock).
+		 */
+		rc = balloon_page_migrate(newpage, page, mode);
+		goto uncharge;
+	}
+
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
@@ -814,7 +830,9 @@ skip_unmap:
 		put_anon_vma(anon_vma);
 
 uncharge:
-	mem_cgroup_end_migration(mem, page, newpage, rc == MIGRATEPAGE_SUCCESS);
+	mem_cgroup_end_migration(mem, page, newpage,
+				 (rc == MIGRATEPAGE_SUCCESS ||
+				  rc == MIGRATEPAGE_BALLOON_SUCCESS));
 unlock:
 	unlock_page(page);
 out:
@@ -846,6 +864,18 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 			goto out;
 
 	rc = __unmap_and_move(page, newpage, force, offlining, mode);
+
+	if (unlikely(rc == MIGRATEPAGE_BALLOON_SUCCESS)) {
+		/*
+		 * A ballooned page has been migrated already.
+		 * Now, it's the time to wrap-up counters,
+		 * handle the page back to Buddy and return.
+		 */
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				    page_is_file_cache(page));
+		balloon_page_free(page);
+		return MIGRATEPAGE_SUCCESS;
+	}
 out:
 	if (rc != -EAGAIN) {
 		/*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
