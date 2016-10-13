Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF466B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 02:45:17 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t73so145736437oie.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 23:45:17 -0700 (PDT)
Received: from SHSQR01.spreadtrum.com ([222.66.158.135])
        by mx.google.com with ESMTPS id l83si4701052oia.31.2016.10.12.23.45.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 23:45:16 -0700 (PDT)
From: "ming.ling" <ming.ling@spreadtrum.com>
Subject: [PATCH v2] mm: exclude isolated non-lru pages from NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Date: Thu, 13 Oct 2016 14:39:09 +0800
Message-ID: <1476340749-13281-1-git-send-email-ming.ling@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, mhocko@suse.com, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, minchan@kernel.org, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com
Cc: riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com, Ming Ling <ming.ling@spreadtrum.com>

From: Ming Ling <ming.ling@spreadtrum.com>

Non-lru pages don't belong to any lru, so counting them to
NR_ISOLATED_ANON or NR_ISOLATED_FILE doesn't make any sense.
It may misguide functions such as pgdat_reclaimable_pages and
too_many_isolated.
On mobile devices such as 512M ram android Phone, it may use
a big zram swap. In some cases zram(zsmalloc) uses too many
non-lru pages, such as:
	MemTotal: 468148 kB
	Normal free:5620kB
	Free swap:4736kB
	Total swap:409596kB
	ZRAM: 164616kB(zsmalloc non-lru pages)
	active_anon:60700kB
	inactive_anon:60744kB
	active_file:34420kB
	inactive_file:37532kB
More non-lru pages which used by zram for swap, it influences
pgdat_reclaimable_pages and too_many_isolated more.
This patch excludes isolated non-lru pages from NR_ISOLATED_ANON
or NR_ISOLATED_FILE to ensure their counts are right.

Signed-off-by: Ming ling <ming.ling@spreadtrum.com>
---
 mm/compaction.c | 6 ++++--
 mm/migrate.c    | 9 +++++----
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0409a4a..ed4c553 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -643,8 +643,10 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 	if (list_empty(&cc->migratepages))
 		return;
 
-	list_for_each_entry(page, &cc->migratepages, lru)
-		count[!!page_is_file_cache(page)]++;
+	list_for_each_entry(page, &cc->migratepages, lru) {
+		if (likely(!__PageMovable(page)))
+			count[!!page_is_file_cache(page)]++;
+	}
 
 	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON, count[0]);
 	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, count[1]);
diff --git a/mm/migrate.c b/mm/migrate.c
index 99250ae..abe48cc 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -168,8 +168,6 @@ void putback_movable_pages(struct list_head *l)
 			continue;
 		}
 		list_del(&page->lru);
-		dec_node_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
 		/*
 		 * We isolated non-lru movable page so here we can use
 		 * __PageMovable because LRU page's mapping cannot have
@@ -185,6 +183,8 @@ void putback_movable_pages(struct list_head *l)
 			unlock_page(page);
 			put_page(page);
 		} else {
+			dec_node_page_state(page, NR_ISOLATED_ANON +
+					page_is_file_cache(page));
 			putback_lru_page(page);
 		}
 	}
@@ -1121,8 +1121,9 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		 * restored.
 		 */
 		list_del(&page->lru);
-		dec_node_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
+		if (likely(!__PageMovable(page)))
+			dec_node_page_state(page, NR_ISOLATED_ANON +
+					page_is_file_cache(page));
 	}
 
 	/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
