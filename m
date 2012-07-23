Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D6A4F6B0088
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:39:01 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 19/34] mm: compaction: make isolate_lru_page() filter-aware again
Date: Mon, 23 Jul 2012 14:38:32 +0100
Message-Id: <1343050727-3045-20-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit c82449352854ff09e43062246af86bdeb628f0c3 upstream.

Stable note: Not tracked in Bugzilla. A fix aimed at preserving page aging
	information by reducing LRU list churning had the side-effect of
	reducing THP allocation success rates. This was part of a series
	to restore the success rates while preserving the reclaim fix.

Commit [39deaf85: mm: compaction: make isolate_lru_page() filter-aware]
noted that compaction does not migrate dirty or writeback pages and
that is was meaningless to pick the page and re-add it to the LRU list.
This had to be partially reverted because some dirty pages can be
migrated by compaction without blocking.

This patch updates "mm: compaction: make isolate_lru_page" by skipping
over pages that migration has no possibility of migrating to minimise
LRU disruption.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel<riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>
Cc: Dave Jones <davej@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andy Isaacson <adi@hexapodia.org>
Cc: Nai Xia <nai.xia@gmail.com>
Cc: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    2 ++
 mm/compaction.c        |    3 +++
 mm/vmscan.c            |   35 +++++++++++++++++++++++++++++++++--
 3 files changed, 38 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 951ed81..80caa71 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -166,6 +166,8 @@ static inline int is_unevictable_lru(enum lru_list l)
 #define ISOLATE_CLEAN		((__force isolate_mode_t)0x4)
 /* Isolate unmapped file */
 #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x8)
+/* Isolate for asynchronous migration */
+#define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x10)
 
 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
diff --git a/mm/compaction.c b/mm/compaction.c
index afdc416..76bdd65 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -371,6 +371,9 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 		}
 
+		if (!cc->sync)
+			mode |= ISOLATE_ASYNC_MIGRATE;
+
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, mode, 0) != 0)
 			continue;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9aa75e9..aa75861 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1045,8 +1045,39 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
 
 	ret = -EBUSY;
 
-	if ((mode & ISOLATE_CLEAN) && (PageDirty(page) || PageWriteback(page)))
-		return ret;
+	/*
+	 * To minimise LRU disruption, the caller can indicate that it only
+	 * wants to isolate pages it will be able to operate on without
+	 * blocking - clean pages for the most part.
+	 *
+	 * ISOLATE_CLEAN means that only clean pages should be isolated. This
+	 * is used by reclaim when it is cannot write to backing storage
+	 *
+	 * ISOLATE_ASYNC_MIGRATE is used to indicate that it only wants to pages
+	 * that it is possible to migrate without blocking
+	 */
+	if (mode & (ISOLATE_CLEAN|ISOLATE_ASYNC_MIGRATE)) {
+		/* All the caller can do on PageWriteback is block */
+		if (PageWriteback(page))
+			return ret;
+
+		if (PageDirty(page)) {
+			struct address_space *mapping;
+
+			/* ISOLATE_CLEAN means only clean pages */
+			if (mode & ISOLATE_CLEAN)
+				return ret;
+
+			/*
+			 * Only pages without mappings or that have a
+			 * ->migratepage callback are possible to migrate
+			 * without blocking
+			 */
+			mapping = page_mapping(page);
+			if (mapping && !mapping->a_ops->migratepage)
+				return ret;
+		}
+	}
 
 	if ((mode & ISOLATE_UNMAPPED) && page_mapped(page))
 		return ret;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
