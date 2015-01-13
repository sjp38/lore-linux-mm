Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8F16B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:21:54 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id n3so6804797wiv.0
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 10:21:53 -0800 (PST)
Received: from mailrelay001.isp.belgacom.be (mailrelay001.isp.belgacom.be. [195.238.6.51])
        by mx.google.com with ESMTP id az8si43127260wjb.176.2015.01.13.10.21.51
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 10:21:51 -0800 (PST)
From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 linux-next] mm,compaction: move suitable_migration_target() under CONFIG_COMPACTION
Date: Tue, 13 Jan 2015 19:21:44 +0100
Message-Id: <1421173304-11514-1-git-send-email-fabf@skynet.be>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Fabian Frederick <fabf@skynet.be>, linux-mm@kvack.org

suitable_migration_target() is only used by isolate_freepages()
Define it under CONFIG_COMPACTION || CONFIG_CMA is not needed.

Fix the following warning:
mm/compaction.c:311:13: warning: 'suitable_migration_target' defined
but not used [-Wunused-function]

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
v2: move function below update_pageblock_skip() instead of above 
isolate_freepages() (suggested by Vlastimil Babka)


 mm/compaction.c | 44 ++++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 22 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 546e571..580790d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -207,6 +207,28 @@ static void update_pageblock_skip(struct compact_control *cc,
 			zone->compact_cached_free_pfn = pfn;
 	}
 }
+
+/* Returns true if the page is within a block suitable for migration to */
+static bool suitable_migration_target(struct page *page)
+{
+	/* If the page is a large free page, then disallow migration */
+	if (PageBuddy(page)) {
+		/*
+		 * We are checking page_order without zone->lock taken. But
+		 * the only small danger is that we skip a potentially suitable
+		 * pageblock, so it's not worth to check order for valid range.
+		 */
+		if (page_order_unsafe(page) >= pageblock_order)
+			return false;
+	}
+
+	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
+	if (migrate_async_suitable(get_pageblock_migratetype(page)))
+		return true;
+
+	/* Otherwise skip the block */
+	return false;
+}
 #else
 static inline bool isolation_suitable(struct compact_control *cc,
 					struct page *page)
@@ -307,28 +329,6 @@ static inline bool compact_should_abort(struct compact_control *cc)
 	return false;
 }
 
-/* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
-{
-	/* If the page is a large free page, then disallow migration */
-	if (PageBuddy(page)) {
-		/*
-		 * We are checking page_order without zone->lock taken. But
-		 * the only small danger is that we skip a potentially suitable
-		 * pageblock, so it's not worth to check order for valid range.
-		 */
-		if (page_order_unsafe(page) >= pageblock_order)
-			return false;
-	}
-
-	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(get_pageblock_migratetype(page)))
-		return true;
-
-	/* Otherwise skip the block */
-	return false;
-}
-
 /*
  * Isolate free pages onto a private freelist. If @strict is true, will abort
  * returning 0 on any invalid PFNs or non-free pages inside of the pageblock
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
