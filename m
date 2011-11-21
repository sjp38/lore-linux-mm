Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6DCDC6B008A
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 13:36:58 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/7] mm: compaction: make isolate_lru_page() filter-aware again
Date: Mon, 21 Nov 2011 18:36:46 +0000
Message-Id: <1321900608-27687-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1321900608-27687-1-git-send-email-mgorman@suse.de>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, LKML <linux-kernel@vger.kernel.org>

Commit [39deaf85: mm: compaction: make isolate_lru_page() filter-aware]
noted that compaction does not migrate dirty or writeback pages and
that is was meaningless to pick the page and re-add it to the LRU list.
This had to be partially reverted because some dirty pages can be
migrated by compaction without blocking.

This patch updates "mm: compaction: make isolate_lru_page" by skipping
over pages that migration has no possibility of migrating to minimise
LRU disruption.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |    2 ++
 mm/compaction.c        |    3 +++
 mm/vmscan.c            |   36 ++++++++++++++++++++++++++++++++++--
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 188cb2f..ac5b522 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -173,6 +173,8 @@ static inline int is_unevictable_lru(enum lru_list l)
 #define ISOLATE_CLEAN		((__force isolate_mode_t)0x4)
 /* Isolate unmapped file */
 #define ISOLATE_UNMAPPED	((__force isolate_mode_t)0x8)
+/* Isolate for asynchronous migration */
+#define ISOLATE_ASYNC_MIGRATE	((__force isolate_mode_t)0x10)
 
 /* LRU Isolation modes. */
 typedef unsigned __bitwise__ isolate_mode_t;
diff --git a/mm/compaction.c b/mm/compaction.c
index 615502b..0379263 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -349,6 +349,9 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 		}
 
+		if (!cc->sync)
+			mode |= ISOLATE_ASYNC_MIGRATE;
+
 		/* Try isolate the page */
 		if (__isolate_lru_page(page, mode, 0) != 0)
 			continue;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3421746..28df0ed 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1061,8 +1061,40 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
 
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
+	 * that it is possible to migrate without blocking with a ->migratepage
+	 * handler
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
+			 * Only the ->migratepage callback knows if a dirty
+			 * page can be migrated without blocking. Skip the
+			 * page unless there is a ->migratepage callback.
+			 */
+			mapping = page_mapping(page);
+			if (!mapping || !mapping->a_ops->migratepage)
+				return ret;
+		}
+	}
 
 	if ((mode & ISOLATE_UNMAPPED) && page_mapped(page))
 		return ret;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
