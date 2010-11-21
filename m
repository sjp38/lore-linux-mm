Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A17BA6B0087
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 09:32:17 -0500 (EST)
Received: by iwn33 with SMTP id 33so2193424iwn.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 06:32:16 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] vmscan: Make move_active_pages_to_lru more generic
Date: Sun, 21 Nov 2010 23:24:56 +0900
Message-Id: <1290349496-13297-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

Now move_active_pages_to_lru can move pages into active or inactive.
if it moves the pages into inactive, it itself can clear PG_acive.
It makes the function more generic.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>

---
 mm/vmscan.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index aa4f1cb..bd408b3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1457,6 +1457,10 @@ static void move_active_pages_to_lru(struct zone *zone,
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
+		/* we are de-activating */
+		if (!is_active_lru(lru))
+			ClearPageActive(page);
+
 		list_move(&page->lru, &zone->lru[lru].list);
 		mem_cgroup_add_lru_list(page, lru);
 		pgmoved++;
@@ -1543,7 +1547,6 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			}
 		}
 
-		ClearPageActive(page);  /* we are de-activating */
 		list_add(&page->lru, &l_inactive);
 	}
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
