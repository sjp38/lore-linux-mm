Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 43D256B006C
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 04:09:47 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2] mm: support MIGRATE_DISCARD
Date: Wed,  5 Sep 2012 17:11:13 +0900
Message-Id: <1346832673-12512-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1346832673-12512-1-git-send-email-minchan@kernel.org>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

This patch introudes MIGRATE_DISCARD mode in migration.
It drops *clean cache pages* instead of migration so that
migration latency could be reduced by avoiding (memcpy + page remapping).
It's useful for CMA because latency of migration is very important rather
than eviction of background processes's workingset. In addition, it needs
less free pages for migration targets so it could avoid memory reclaiming
to get free pages, which is another factor increase latency.

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/migrate_mode.h |    7 +++++++
 mm/migrate.c                 |   41 ++++++++++++++++++++++++++++++++++++++---
 mm/page_alloc.c              |    2 +-
 3 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 8848cad..4eb1646 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -14,6 +14,13 @@
  */
 #define MIGRATE_SYNC		((__force migrate_mode_t)0x4)
 
+/*
+ * MIGRTATE_DISCARD will discard clean cache page instead of migration.
+ * MIGRATE_ASYNC, MIGRATE_SYNC_LIGHT, MIGRATE_SYNC shouldn't be used
+ * together with OR flag in current implementation.
+ */
+#define MIGRATE_DISCARD		((__force migrate_mode_t)0x8)
+
 typedef unsigned __bitwise__ migrate_mode_t;
 
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/migrate.c b/mm/migrate.c
index 28d464b..2de7709 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -678,6 +678,19 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 	return rc;
 }
 
+static int discard_page(struct page *page)
+{
+	int ret = -EAGAIN;
+
+	struct address_space *mapping = page_mapping(page);
+	if (page_has_private(page))
+		if (!try_to_release_page(page, GFP_KERNEL))
+			return ret;
+	if (remove_mapping(mapping, page))
+		ret = 0;
+	return ret;
+}
+
 static int __unmap_and_move(struct page *page, struct page *newpage,
 			int force, bool offlining, migrate_mode_t mode)
 {
@@ -685,6 +698,9 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	int remap_swapcache = 1;
 	struct mem_cgroup *mem;
 	struct anon_vma *anon_vma = NULL;
+	enum ttu_flags ttu_flags;
+	bool discard_mode = false;
+	bool file = false;
 
 	if (!trylock_page(page)) {
 		if (!force || (mode & MIGRATE_ASYNC))
@@ -799,12 +815,31 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 		goto skip_unmap;
 	}
 
+	file = page_is_file_cache(page);
+	ttu_flags = TTU_IGNORE_ACCESS;
+retry:
+	if (!(mode & MIGRATE_DISCARD) || !file || PageDirty(page))
+		ttu_flags |= (TTU_MIGRATION | TTU_IGNORE_MLOCK);
+	else
+		discard_mode = true;
+
 	/* Establish migration ptes or remove ptes */
-	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
+	rc = try_to_unmap(page, ttu_flags);
 
 skip_unmap:
-	if (!page_mapped(page))
-		rc = move_to_new_page(newpage, page, remap_swapcache, mode);
+	if (rc == SWAP_SUCCESS) {
+		if (!discard_mode) {
+			rc = move_to_new_page(newpage, page,
+					remap_swapcache, mode);
+		} else {
+			rc = discard_page(page);
+			goto uncharge;
+		}
+	} else if (rc == SWAP_MLOCK && discard_mode) {
+		mode &= ~MIGRATE_DISCARD;
+		discard_mode = false;
+		goto retry;
+	}
 
 	if (rc && remap_swapcache)
 		remove_migration_ptes(page, page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ba3100a..e14b960 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5670,7 +5670,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 
 		ret = migrate_pages(&cc.migratepages,
 				    __alloc_contig_migrate_alloc,
-				    0, false, MIGRATE_SYNC);
+				    0, false, MIGRATE_SYNC|MIGRATE_DISCARD);
 	}
 
 	putback_lru_pages(&cc.migratepages);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
