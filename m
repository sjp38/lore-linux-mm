Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0E8F66B006A
	for <linux-mm@kvack.org>; Sun, 10 Jan 2010 23:37:35 -0500 (EST)
Received: by qw-out-1920.google.com with SMTP id 5so5484300qwc.44
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 20:37:34 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH 2/4] mm/page_alloc : relieve the zone->lock's pressure for allocation
Date: Mon, 11 Jan 2010 12:37:12 +0800
Message-Id: <1263184634-15447-2-git-send-email-shijie8@gmail.com>
In-Reply-To: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

  The __mod_zone_page_state() only require irq disabling,
it does not require the zone's spinlock. So move it out of
the guard region of the spinlock to relieve the pressure for
allocation.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 23df1ed..00aa83a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -961,8 +961,8 @@ static int rmqueue_single(struct zone *zone, unsigned long count,
 		set_page_private(page, migratetype);
 		list = &page->lru;
 	}
-	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
 	spin_unlock(&zone->lock);
+	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
 	return i;
 }
 
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
