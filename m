Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 018B06B025E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:33:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 128so33208975pfz.1
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 22:33:41 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id ae6si6179447pad.277.2016.10.11.22.33.40
        for <linux-mm@kvack.org>;
        Tue, 11 Oct 2016 22:33:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/4] mm: don't steal highatomic pageblock
Date: Wed, 12 Oct 2016 14:33:33 +0900
Message-Id: <1476250416-22733-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1476250416-22733-1-git-send-email-minchan@kernel.org>
References: <1476250416-22733-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

In page freeing path, migratetype is racy so that a highorderatomic
page could free into non-highorderatomic free list. If that page
is allocated, VM can change the pageblock from higorderatomic to
something. In that case, highatomic pageblock accounting is broken
so it doesn't work(e.g., VM cannot reserve highorderatomic pageblocks
any more although it doesn't reach 1% limit).

So, this patch prohibits the changing from highatomic to other type.
It's no problem because MIGRATE_HIGHATOMIC is not listed in fallback
array so stealing will only happen due to unexpected races which is
really rare. Also, such prohibiting keeps highatomic pageblock more
longer so it would be better for highorderatomic page allocation.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 55ad0229ebf3..79853b258211 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2154,7 +2154,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 
 		page = list_first_entry(&area->free_list[fallback_mt],
 						struct page, lru);
-		if (can_steal)
+		if (can_steal &&
+			get_pageblock_migratetype(page) != MIGRATE_HIGHATOMIC)
 			steal_suitable_fallback(zone, page, start_migratetype);
 
 		/* Remove the page from the freelists */
@@ -2555,7 +2556,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
-			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
+			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)
+				&& mt != MIGRATE_HIGHATOMIC)
 				set_pageblock_migratetype(page,
 							  MIGRATE_MOVABLE);
 		}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
