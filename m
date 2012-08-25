Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 6E5946B002B
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 01:25:26 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH v9 2/5] mm: introduce compaction and migration for ballooned pages
Date: Sat, 25 Aug 2012 02:24:57 -0300
Message-Id: <c284efbe61157e6164af01d0e362a222a53a075a.1345869378.git.aquini@redhat.com>
In-Reply-To: <cover.1345869378.git.aquini@redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
In-Reply-To: <cover.1345869378.git.aquini@redhat.com>
References: <cover.1345869378.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rafael Aquini <aquini@redhat.com>

Memory fragmentation introduced by ballooning might reduce significantly
the number of 2MB contiguous memory blocks that can be used within a guest,
thus imposing performance penalties associated with the reduced number of
transparent huge pages that could be used by the guest workload.

This patch introduces the helper functions as well as the necessary changes
to teach compaction and migration bits how to cope with pages which are
part of a guest memory balloon, in order to make them movable by memory
compaction procedures.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 mm/compaction.c | 47 ++++++++++++++++++++++++++++-------------------
 mm/migrate.c    | 36 ++++++++++++++++++++++++++++++++++--
 2 files changed, 62 insertions(+), 21 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7fcd3a5..e50836b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -14,6 +14,7 @@
 #include <linux/backing-dev.h>
 #include <linux/sysctl.h>
 #include <linux/sysfs.h>
+#include <linux/balloon_compaction.h>
 #include "internal.h"
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
@@ -358,32 +359,40 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			continue;
 		}
 
-		if (!PageLRU(page))
-			continue;
-
 		/*
-		 * PageLRU is set, and lru_lock excludes isolation,
-		 * splitting and collapsing (collapsing has already
-		 * happened if PageLRU is set).
+		 * It is possible to migrate LRU pages and balloon pages.
+		 * Skip any other type of page.
 		 */
-		if (PageTransHuge(page)) {
-			low_pfn += (1 << compound_order(page)) - 1;
-			continue;
-		}
+		if (PageLRU(page)) {
+			/*
+			 * PageLRU is set, and lru_lock excludes isolation,
+			 * splitting and collapsing (collapsing has already
+			 * happened if PageLRU is set).
+			 */
+			if (PageTransHuge(page)) {
+				low_pfn += (1 << compound_order(page)) - 1;
+				continue;
+			}
 
-		if (!cc->sync)
-			mode |= ISOLATE_ASYNC_MIGRATE;
+			if (!cc->sync)
+				mode |= ISOLATE_ASYNC_MIGRATE;
 
-		lruvec = mem_cgroup_page_lruvec(page, zone);
+			lruvec = mem_cgroup_page_lruvec(page, zone);
 
-		/* Try isolate the page */
-		if (__isolate_lru_page(page, mode) != 0)
-			continue;
+			/* Try isolate the page */
+			if (__isolate_lru_page(page, mode) != 0)
+				continue;
 
-		VM_BUG_ON(PageTransCompound(page));
+			VM_BUG_ON(PageTransCompound(page));
+
+			/* Successfully isolated */
+			del_page_from_lru_list(page, lruvec, page_lru(page));
+		} else if (unlikely(movable_balloon_page(page))) {
+			if (!isolate_balloon_page(page))
+				continue;
+		} else
+			continue;
 
-		/* Successfully isolated */
-		del_page_from_lru_list(page, lruvec, page_lru(page));
 		list_add(&page->lru, migratelist);
 		cc->nr_migratepages++;
 		nr_isolated++;
diff --git a/mm/migrate.c b/mm/migrate.c
index 77ed2d7..ec439f8 100644
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
+		if (unlikely(movable_balloon_page(page)))
+			putback_balloon_page(page);
+		else
+			putback_lru_page(page);
 	}
 }
 
@@ -799,6 +803,18 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		goto skip_unmap;
 	}
 
+	if (unlikely(movable_balloon_page(page))) {
+		/*
+		 * A ballooned page does not need any special attention from
+		 * physical to virtual reverse mapping procedures.
+		 * Skip any attempt to unmap PTEs or to remap swap cache,
+		 * in order to avoid burning cycles at rmap level, and perform
+		 * the page migration right away (proteced by page lock).
+		 */
+		rc = migrate_balloon_page(newpage, page, mode);
+		goto uncharge;
+	}
+
 	/* Establish migration ptes or remove ptes */
 	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 
@@ -814,7 +830,8 @@ skip_unmap:
 		put_anon_vma(anon_vma);
 
 uncharge:
-	mem_cgroup_end_migration(mem, page, newpage, rc == 0);
+	mem_cgroup_end_migration(mem, page, newpage,
+				 (rc == 0 || rc == BALLOON_MIGRATION_RETURN));
 unlock:
 	unlock_page(page);
 out:
@@ -846,6 +863,21 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
 			goto out;
 
 	rc = __unmap_and_move(page, newpage, force, offlining, mode);
+
+	if (unlikely(rc == BALLOON_MIGRATION_RETURN)) {
+		/*
+		 * A ballooned page has been migrated already.
+		 * Now, it's the time to remove the old page from the isolated
+		 * pageset list and handle it back to Buddy, wrap-up counters
+		 * and return.
+		 */
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				    page_is_file_cache(page));
+		list_del(&page->lru);
+		put_page(page);
+		__free_page(page);
+		return 0;
+	}
 out:
 	if (rc != -EAGAIN) {
 		/*
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
