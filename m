Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 969376B0260
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 09:35:59 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id tb5so46957957lbb.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 06:35:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g69si19415559wme.83.2016.04.25.06.35.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Apr 2016 06:35:56 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH mmotm 3/3] mm, compaction: prevent nr_isolated_* from going negative
Date: Mon, 25 Apr 2016 15:35:50 +0200
Message-Id: <1461591350-28700-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1461591350-28700-1-git-send-email-vbabka@suse.cz>
References: <1461591269-28615-1-git-send-email-vbabka@suse.cz>
 <1461591350-28700-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

From: Hugh Dickins <hughd@google.com>

/proc/sys/vm/stat_refresh warns nr_isolated_anon and nr_isolated_file
go increasingly negative under compaction: which would add delay when
should be none, or no delay when should delay.  putback_movable_pages()
decrements the NR_ISOLATED counts which acct_isolated() increments,
so isolate_migratepages_block() needs to acct before putback in that
special case. It's also useful to reset cc->nr_migratepages after putback
so we don't needlessly return too early on the COMPACT_CLUSTER_MAX check.

Also it's easier to track the life of cc->migratepages if we don't assign
it to a migratelist variable.

Fixes: mmotm mm-compaction-skip-blocks-where-isolation-fails-in-async-direct-compaction.patch
Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/compaction.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6a49d1b35515..78552009e6ec 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -638,7 +638,6 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 {
 	struct zone *zone = cc->zone;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
-	struct list_head *migratelist = &cc->migratepages;
 	struct lruvec *lruvec;
 	unsigned long flags = 0;
 	bool locked = false;
@@ -812,7 +811,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 
 isolate_success:
-		list_add(&page->lru, migratelist);
+		list_add(&page->lru, &cc->migratepages);
 		cc->nr_migratepages++;
 		nr_isolated++;
 
@@ -846,9 +845,11 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 				spin_unlock_irqrestore(&zone->lru_lock,	flags);
 				locked = false;
 			}
-			putback_movable_pages(migratelist);
-			nr_isolated = 0;
+			acct_isolated(zone, cc);
+			putback_movable_pages(&cc->migratepages);
+			cc->nr_migratepages = 0;
 			cc->last_migrated_pfn = 0;
+			nr_isolated = 0;
 		}
 
 		if (low_pfn < next_skip_pfn) {
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
