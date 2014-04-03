Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC0A6B0036
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 11:40:44 -0400 (EDT)
Received: by mail-bk0-f48.google.com with SMTP id mx12so195215bkb.35
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 08:40:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xu2si2594690bkb.336.2014.04.03.08.40.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 08:40:43 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/2] mm/page_alloc: DEBUG_VM checks for free_list placement of CMA and RESERVE pages
Date: Thu,  3 Apr 2014 17:40:18 +0200
Message-Id: <1396539618-31362-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1396539618-31362-1-git-send-email-vbabka@suse.cz>
References: <533D8015.1000106@suse.cz>
 <1396539618-31362-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Yong-Taek Lee <ytk.lee@samsung.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michal Nazarewicz <mina86@mina86.com>

For the MIGRATE_RESERVE pages, it is important they do not get misplaced
on free_list of other migratetype, otherwise the whole MIGRATE_RESERVE
pageblock might be changed to other migratetype in try_to_steal_freepages().
For MIGRATE_CMA, the pages also must not go to a different free_list, otherwise
they could get allocated as unmovable and result in CMA failure.

This is ensured by setting the freepage_migratetype appropriately when placing
pages on pcp lists, and using the information when releasing them back to
free_list. It is also assumed that CMA and RESERVE pageblocks are created only
in the init phase. This patch adds DEBUG_VM checks to catch any regressions
introduced for this invariant.

Cc: Yong-Taek Lee <ytk.lee@samsung.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mm.h | 19 +++++++++++++++++++
 mm/page_alloc.c    |  3 +++
 2 files changed, 22 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c1b7414..27a74ba 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -280,6 +280,25 @@ static inline int get_freepage_migratetype(struct page *page)
 }
 
 /*
+ * Check that a freepage cannot end up on a wrong free_list for "sensitive"
+ * migratetypes. Return false if it could. Useful for VM_BUG_ON checks.
+ */
+static inline bool check_freepage_migratetype(struct page *page)
+{
+	int pageblock_mt = get_pageblock_migratetype(page);
+	int freepage_mt = get_freepage_migratetype(page);
+
+	/*
+	 * For RESERVE and CMA pageblocks, the freepage_migratetype must
+	 * match their migratetype. For other pageblocks, we don't care.
+	 */
+	if (pageblock_mt != MIGRATE_RESERVE && !is_migrate_cma(pageblock_mt))
+		return true;
+
+	return (freepage_mt == pageblock_mt);
+}
+
+/*
  * FIXME: take this include out, include page-flags.h in
  * files which need it (119 of them)
  */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2dbaba1..0ee9f8c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -697,6 +697,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
+
+			VM_BUG_ON(!check_freepage_migratetype(page));
 			mt = get_freepage_migratetype(page);
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, zone, 0, mt);
@@ -1190,6 +1192,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		struct page *page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
 			break;
+		VM_BUG_ON(!check_freepage_migratetype(page));
 
 		/*
 		 * Split buddy pages returned by expand() are received here
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
