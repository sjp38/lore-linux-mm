Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5846B007D
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:39:08 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 12so3429632pwi.14
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 07:39:05 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 03/10] Add additional isolation mode
Date: Tue,  7 Jun 2011 23:38:16 +0900
Message-Id: <b72a86ed33c693aeccac0dba3fba8c13145106ab.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

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
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/swap.h |    2 ++
 mm/vmscan.c          |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 48d50e6..731f5dd 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -248,6 +248,8 @@ enum ISOLATE_MODE {
 	ISOLATE_NONE,
 	ISOLATE_INACTIVE = 1,	/* Isolate inactive pages */
 	ISOLATE_ACTIVE = 2,	/* Isolate active pages */
+	ISOLATE_CLEAN = 8,      /* Isolate clean file */
+	ISOLATE_UNMAPPED = 16,  /* Isolate unmapped file */
 };
 
 /* linux/mm/vmscan.c */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4cbe114..26aa627 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -990,6 +990,12 @@ int __isolate_lru_page(struct page *page, enum ISOLATE_MODE mode, int file)
 
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
