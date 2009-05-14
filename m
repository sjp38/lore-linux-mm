Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1F7126B0177
	for <linux-mm@kvack.org>; Thu, 14 May 2009 01:10:34 -0400 (EDT)
Received: by pzk5 with SMTP id 5so522729pzk.12
        for <linux-mm@kvack.org>; Wed, 13 May 2009 22:10:42 -0700 (PDT)
Date: Thu, 14 May 2009 14:10:25 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] Prevent shrinking of active anon lru list in case of no
 swap space
Message-Id: <20090514141025.239cafe5.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


Now shrink_active_list is called several places.
But if we don't have a swap space, we can't reclaim anon pages.
So, we don't need deactivating anon pages in anon lru list.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2f9d555..e4d71f4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1238,6 +1238,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	enum lru_list lru;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
+	/* 
+	 * we can't shrink anon list in case of no swap space.
+	 */
+	if (file == 0 && nr_swap_pages <= 0)
+		return;
+
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
-- 
1.5.4.3


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
