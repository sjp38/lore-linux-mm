Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A9F59600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 21:22:33 -0500 (EST)
Received: by yxe36 with SMTP id 36so15784373yxe.11
        for <linux-mm@kvack.org>; Sun, 03 Jan 2010 18:22:32 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] mm : add check for the return value
Date: Mon,  4 Jan 2010 10:22:10 +0800
Message-Id: <1262571730-2778-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

When the `page' returned by __rmqueue() is NULL, the origin code
still adds -(1 << order) to zone's NR_FREE_PAGES item.

The patch fixes it.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/page_alloc.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e9f5cc..620921d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1222,10 +1222,14 @@ again:
 		}
 		spin_lock_irqsave(&zone->lock, flags);
 		page = __rmqueue(zone, order, migratetype);
-		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
-		spin_unlock(&zone->lock);
-		if (!page)
+		if (likely(page)) {
+			__mod_zone_page_state(zone, NR_FREE_PAGES,
+						-(1 << order));
+			spin_unlock(&zone->lock);
+		} else {
+			spin_unlock(&zone->lock);
 			goto failed;
+		}
 	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
