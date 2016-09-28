Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38E9B6B0297
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 05:35:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 21so81664117pfy.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 02:35:40 -0700 (PDT)
Received: from SHSQR01.spreadtrum.com ([222.66.158.135])
        by mx.google.com with ESMTPS id a69si7689608pfc.119.2016.09.28.02.35.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Sep 2016 02:35:39 -0700 (PDT)
From: "ming.ling" <ming.ling@spreadtrum.com>
Subject: [PATCH] mm: exclude isolated non-lru pages from NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Date: Wed, 28 Sep 2016 17:31:03 +0800
Message-ID: <1475055063-1588-1-git-send-email-ming.ling@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, mhocko@suse.com, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, minchan@kernel.org, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com
Cc: riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "ming.ling" <ming.ling@spreadtrum.com>

Non-lru pages don't belong to any lru, so accounting them to
NR_ISOLATED_ANON or NR_ISOLATED_FILE doesn't make any sense.
It may misguide functions such as pgdat_reclaimable_pages and
too_many_isolated.

This patch adds NR_ISOLATED_NONLRU to vmstat and moves isolated non-lru
pages from NR_ISOLATED_ANON or NR_ISOLATED_FILE to NR_ISOLATED_NONLRU.
And with non-lru pages in vmstat, it helps to optimize algorithm of
function too_many_isolated oneday.

Signed-off-by: ming.ling <ming.ling@spreadtrum.com>
---
 include/linux/mmzone.h |  1 +
 mm/compaction.c        | 12 +++++++++---
 mm/migrate.c           | 14 ++++++++++----
 3 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7f2ae99..dc0adba 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -169,6 +169,7 @@ enum node_stat_item {
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
+	NR_ISOLATED_NONLRU,	/* Temporary isolated pages from non-lru */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 9affb29..8da1dca 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -638,16 +638,21 @@ isolate_freepages_range(struct compact_control *cc,
 static void acct_isolated(struct zone *zone, struct compact_control *cc)
 {
 	struct page *page;
-	unsigned int count[2] = { 0, };
+	unsigned int count[3] = { 0, };
 
 	if (list_empty(&cc->migratepages))
 		return;
 
-	list_for_each_entry(page, &cc->migratepages, lru)
-		count[!!page_is_file_cache(page)]++;
+	list_for_each_entry(page, &cc->migratepages, lru) {
+		if (PageLRU(page))
+			count[!!page_is_file_cache(page)]++;
+		else
+			count[2]++;
+	}
 
 	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON, count[0]);
 	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, count[1]);
+	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_NONLRU, count[2]);
 }
 
 /* Similar to reclaim, but different enough that they don't share logic */
@@ -659,6 +664,7 @@ static bool too_many_isolated(struct zone *zone)
 			node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
 	active = node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE) +
 			node_page_state(zone->zone_pgdat, NR_ACTIVE_ANON);
+	/* Is it necessary to add NR_ISOLATED_NONLRU?? */
 	isolated = node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE) +
 			node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index f7ee04a..cd5abb2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -168,8 +168,11 @@ void putback_movable_pages(struct list_head *l)
 			continue;
 		}
 		list_del(&page->lru);
-		dec_node_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
+		if (PageLRU(page))
+			dec_node_page_state(page, NR_ISOLATED_ANON +
+					page_is_file_cache(page));
+		else
+			dec_node_page_state(page, NR_ISOLATED_NONLRU);
 		/*
 		 * We isolated non-lru movable page so here we can use
 		 * __PageMovable because LRU page's mapping cannot have
@@ -1121,8 +1124,11 @@ out:
 		 * restored.
 		 */
 		list_del(&page->lru);
-		dec_node_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
+		if (PageLRU(page))
+			dec_node_page_state(page, NR_ISOLATED_ANON +
+					page_is_file_cache(page));
+		else
+			dec_node_page_state(page, NR_ISOLATED_NONLRU);
 	}
 
 	/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
