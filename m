Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 06D3F6B0025
	for <linux-mm@kvack.org>; Sun, 29 May 2011 14:14:17 -0400 (EDT)
Received: by mail-px0-f177.google.com with SMTP id 10so2040762pxi.8
        for <linux-mm@kvack.org>; Sun, 29 May 2011 11:14:17 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 04/10] Add additional isolation mode
Date: Mon, 30 May 2011 03:13:43 +0900
Message-Id: <5b0f0be7ee441ea27ffcad81d2637ac09407acf3.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1306689214.git.minchan.kim@gmail.com>
References: <cover.1306689214.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>

There are some places to isolate lru page and I believe
users of isolate_lru_page will be growing.
The purpose of them is each different so part of isolated pages
should put back to LRU, again.

The problem is when we put back the page into LRU,
we lose LRU ordering and the page is inserted at head of LRU list.
It makes unnecessary LRU churning so that vm can evict working set pages
rather than idle pages.

This patch adds new modes when we isolate page in LRU so we don't isolate pages
if we can't handle it. It could reduce LRU churning.

This patch doesn't change old behavior. It's just used by next patches.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/swap.h |    2 ++
 mm/vmscan.c          |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 37e4591..2718f8c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -249,6 +249,8 @@ enum ISOLATE_PAGE_MODE {
 	ISOLATE_INACTIVE = 1,	/* Isolate inactive pages */
 	ISOLATE_ACTIVE = 2,	/* Isolate active pages */
 	ISOLATE_BOTH = 4,	/* Isolate both active and inactive pages */
+	ISOLATE_CLEAN = 8,	/* Isolate clean file */
+	ISOLATE_UNMAPPED = 16,	/* Isolate unmapped file */
 };
 
 /* linux/mm/vmscan.c */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f03bb2e..9972356 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -992,6 +992,12 @@ int __isolate_lru_page(struct page *page, enum ISOLATE_PAGE_MODE mode,
 
 	ret = -EBUSY;
 
+	if (mode & ISOLATE_CLEAN && (PageDirty(page) || PageWriteback(page)))
+		return ret;
+
+	if (mode & ISOLATE_UNMAPPED && page_mapped(page))
+		return ret;
+
 	if (likely(get_page_unless_zero(page))) {
 		/*
 		 * Be careful not to clear PageLRU until after we're
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
